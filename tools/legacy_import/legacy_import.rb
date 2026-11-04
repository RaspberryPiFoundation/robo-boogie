# frozen_string_literal: true

require "json"
require "open3"
require "securerandom"
require "sequel"
require "zlib"

# Copies dances from a mysqldump of the legacy PHP app's MySQL database into
# the new app's Postgres. See README.md in this directory.
module LegacyImport
  # One JSON object per legacy dance, with its robot, soundtrack and owner
  # joined the way the PHP API read them. Each relationship lives in a join
  # table; where a dance has several rows, the first (lowest id) is used and
  # the count is kept so the import can report it.
  EXPORT_SQL = <<~SQL
    SELECT JSON_OBJECT(
      'id', d.id,
      'guid', d.guid,
      'robot_name', d.robot_name,
      'move', d.move,
      'is_entered_into_comp', d.is_entered_into_comp,
      'date_created', d.date_created,
      'date_updated', d.date_updated,
      'robot_id', r.id,
      'robot_links', COALESCE(rl.links, 0),
      'sound_id', s.id,
      'sound_links', COALESCE(sl.links, 0),
      'owner_uuid', u.uuid,
      'owner_links', COALESCE(ul.links, 0)
    )
    FROM dances d
    LEFT JOIN (SELECT dance_id, MIN(id) AS first_id, COUNT(*) AS links FROM dances_robots GROUP BY dance_id) rl ON rl.dance_id = d.id
    LEFT JOIN dances_robots dr ON dr.id = rl.first_id
    LEFT JOIN robots r ON r.id = dr.robot_id
    LEFT JOIN (SELECT dance_id, MIN(id) AS first_id, COUNT(*) AS links FROM dances_soundtracks GROUP BY dance_id) sl ON sl.dance_id = d.id
    LEFT JOIN dances_soundtracks ds ON ds.id = sl.first_id
    LEFT JOIN soundtracks s ON s.id = ds.soundtrack_id
    LEFT JOIN (SELECT dance_id, MIN(id) AS first_id, COUNT(*) AS links FROM dances_users GROUP BY dance_id) ul ON ul.dance_id = d.id
    LEFT JOIN dances_users du ON du.id = ul.first_id
    LEFT JOIN users u ON u.id = du.user_id
    ORDER BY d.id
  SQL

  # What each reported issue means, and what the import did about it.
  ISSUES = {
    missing_guid: "No guid, so it can't be linked to: skipped",
    duplicate_guid: "Guid already used by a lower id (the one the PHP API showed): skipped",
    invalid_move: "Move isn't a JSON object: imported with an empty move, as the PHP API returned it",
    no_owner: "No owner: imported, but nobody can edit it (as before)",
    several_owners: "Several owner links: the first was used",
    no_robot: "No robot, or one that doesn't exist: imported without one (as before)",
    several_robots: "Several robot links: the first was used",
    no_soundtrack: "No soundtrack: imported without one (plays the default, as before)",
    several_soundtracks: "Several soundtrack links: the first was used",
    no_timestamps: "No created or updated time: imported with 1970-01-01",
    non_ascii_name: "Name has non-ASCII characters: imported as-is (worth spot-checking)"
  }.freeze

  EXAMPLES_PER_ISSUE = 50
  SAMPLE_SIZE = 1_000

  # Turns export rows into rows for the new dances table, keeping a tally of
  # anything unusual and a random sample of guids for verify.rb.
  class Transformer
    attr_reader :issues, :rows_read, :rows_kept, :sample

    def initialize(random: Random.new)
      @random = random
      @seen_guids = {}
      @issues = Hash.new { |hash, key| hash[key] = { count: 0, examples: [] } }
      @rows_read = 0
      @rows_kept = 0
      @sample = []
    end

    # Returns the attributes to store, or nil if the row is skipped.
    def call(row)
      @rows_read += 1
      guid = row["guid"].to_s
      return note(:missing_guid, "id #{row["id"]}") if guid.empty?
      return note(:duplicate_guid, guid) if @seen_guids.key?(guid)

      @seen_guids[guid] = true
      check_links(row, guid)
      created_at, updated_at = timestamps(row, guid)
      note(:non_ascii_name, guid) unless row["robot_name"].to_s.ascii_only?

      keep(guid)
      {
        id: row.fetch("id"),
        guid: guid,
        owner_uuid: row["owner_uuid"],
        robot_id: row["robot_id"],
        sound_id: row["sound_id"],
        robot_name: row["robot_name"]&.delete("\u0000"),
        move: move_json(row["move"], guid),
        is_entered_into_comp: row["is_entered_into_comp"].to_i == 1,
        created_at: created_at,
        updated_at: updated_at
      }
    end

    def report
      {
        rows_read: rows_read,
        rows_kept: rows_kept,
        issues: ISSUES.keys.filter_map do |key|
          next unless @issues.key?(key)

          { issue: key, meaning: ISSUES.fetch(key) }.merge(@issues[key])
        end,
        sample_guids: sample
      }
    end

    private

    def note(issue, example)
      entry = @issues[issue]
      entry[:count] += 1
      entry[:examples] << example if entry[:examples].length < EXAMPLES_PER_ISSUE
      nil
    end

    def check_links(row, guid)
      note(:no_owner, guid) if row["owner_uuid"].nil?
      note(:several_owners, guid) if row["owner_links"].to_i > 1
      note(:no_robot, guid) if row["robot_id"].nil?
      note(:several_robots, guid) if row["robot_links"].to_i > 1
      note(:no_soundtrack, guid) if row["sound_id"].nil?
      note(:several_soundtracks, guid) if row["sound_links"].to_i > 1
    end

    # The stored text is kept byte-for-byte when it's a JSON object, so key
    # order and values match what the PHP API served.
    def move_json(raw, guid)
      parsed = JSON.parse(raw.to_s)
      return raw if parsed.is_a?(Hash)

      note(:invalid_move, guid)
      "{}"
    rescue JSON::ParserError
      note(:invalid_move, guid)
      "{}"
    end

    def timestamps(row, guid)
      created = row["date_created"] || row["date_updated"]
      updated = row["date_updated"] || row["date_created"]
      note(:no_timestamps, guid) if created.nil?
      [Time.at(created.to_i).utc, Time.at(updated.to_i).utc]
    end

    # Reservoir sampling, so the sample is uniform without holding every guid.
    def keep(guid)
      @rows_kept += 1
      if @sample.length < SAMPLE_SIZE
        @sample << guid
      else
        slot = @random.rand(@rows_kept)
        @sample[slot] = guid if slot < SAMPLE_SIZE
      end
    end
  end

  # Upserts transformed rows into the new dances table.
  class Loader
    COLUMNS = %i[id guid owner_uuid robot_id sound_id robot_name move is_entered_into_comp created_at updated_at].freeze
    UPDATED_COLUMNS = (COLUMNS - %i[id guid created_at]).freeze
    BATCH_SIZE = 1_000

    # New dances get ids at least this far above the highest legacy id, so
    # dances saved on the old server during cutover can still be imported
    # with their own ids.
    ID_GAP = 1_000_000

    attr_reader :legacy_max_id

    def initialize(db)
      @db = db
      @legacy_max_id = 0
    end

    # Re-running with a newer dump only changes dances whose updated time is
    # newer, so it's safe to repeat (that's how the cutover catches up).
    def load(rows)
      @db.transaction do
        rows.each_slice(BATCH_SIZE) { |batch| upsert(batch) }
        move_id_sequence_past_legacy_ids
      end
    end

    private

    def upsert(batch)
      @legacy_max_id = [@legacy_max_id, *batch.map { |row| row[:id] }].max
      values = batch.map do |row|
        COLUMNS.map { |column| column == :move ? Sequel.cast(row[:move], :json) : row[column] }
      end

      @db[:dances].insert_conflict(
        target: :guid,
        update: UPDATED_COLUMNS.to_h { |column| [column, Sequel[:excluded][column]] },
        update_where: Sequel[:dances][:updated_at] < Sequel[:excluded][:updated_at]
      ).import(COLUMNS, values)
    rescue Sequel::UniqueConstraintViolation => e
      raise e.class, "#{e.message.lines.first.strip}. A legacy dance id is already used by a different " \
                     "dance, probably one saved on the new app before the first import. Delete it and re-run."
    end

    def move_id_sequence_past_legacy_ids
      return if @legacy_max_id.zero?

      sequence = @db.get(Sequel.function(:pg_get_serial_sequence, "dances", "id"))
      state = @db.fetch("SELECT last_value, is_called FROM #{sequence}").first
      next_id = state[:is_called] ? state[:last_value] + 1 : state[:last_value]
      floor = @legacy_max_id + ID_GAP
      @db.get(Sequel.function(:setval, sequence, floor, false)) if next_id < floor
    end
  end

  # A throwaway MySQL server in Docker that the dump is restored into, so
  # MySQL itself deals with the dump's escaping and character sets.
  class MySQLContainer
    IMAGE = "mysql:8.4"
    READY_TIMEOUT = 180

    def initialize(image: IMAGE, log: $stderr)
      @image = image
      @log = log
      @name = "roboboogie-legacy-import-#{Process.pid}"
      @password = SecureRandom.hex(16)
    end

    def self.open(**options)
      container = new(**options)
      container.start
      yield container
    ensure
      container&.stop
    end

    def start
      run!("docker", "run", "--detach", "--rm", "--name", @name,
           "-e", "MYSQL_ROOT_PASSWORD=#{@password}", "-e", "MYSQL_DATABASE=legacy", @image)
      wait_until_ready
    end

    def stop
      system("docker", "rm", "--force", @name, out: File::NULL, err: File::NULL)
    end

    def restore(dump_path)
      IO.popen(mysql_command("legacy", stdin: true), "w") do |mysql|
        open_dump(dump_path) { |dump| IO.copy_stream(dump, mysql) }
      end
      raise "Restoring #{dump_path} failed (see MySQL's error above)" unless $?.success?
    end

    # The database holding the dances table: "legacy", unless the dump
    # selected its own (mysqldump --databases adds a USE statement).
    def dances_database
      schemas = query_lines("SELECT table_schema FROM information_schema.tables WHERE table_name = 'dances'")
      raise "The dump has no dances table" if schemas.empty?
      raise "The dump has several dances tables (#{schemas.join(", ")})" if schemas.length > 1

      schemas.first
    end

    def each_export_row(database)
      IO.popen(mysql_command(database, "--batch", "--raw", "--quick", "--skip-column-names", "-e", EXPORT_SQL),
               external_encoding: Encoding::UTF_8) do |io|
        io.each_line { |line| yield JSON.parse(line) }
      end
      raise "Exporting dances from MySQL failed (see MySQL's error above)" unless $?.success?
    end

    private

    def mysql_command(database, *args, stdin: false)
      ["docker", "exec", *("-i" if stdin), "-e", "MYSQL_PWD=#{@password}", @name,
       "mysql", "--host=127.0.0.1", "--user=root", "--default-character-set=utf8mb4", *args, database]
    end

    def query_lines(sql)
      output, status = Open3.capture2(*mysql_command("information_schema", "--batch", "--skip-column-names", "-e", sql))
      raise "MySQL query failed: #{sql}" unless status.success?

      output.lines.map(&:strip).reject(&:empty?)
    end

    # The image's entrypoint runs a temporary server without networking
    # first, so only a TCP connection proves the real server is up.
    def wait_until_ready
      deadline = Time.now + READY_TIMEOUT
      until system(*mysql_command("legacy", "-e", "SELECT 1"), out: File::NULL, err: File::NULL)
        raise "MySQL didn't start within #{READY_TIMEOUT}s" if Time.now > deadline

        sleep 1
      end
    end

    def open_dump(path, &block)
      if path.end_with?(".gz")
        Zlib::GzipReader.open(path, &block)
      else
        File.open(path, "rb", &block)
      end
    end

    def run!(*command)
      _output, error, status = Open3.capture3(*command)
      raise "#{command.first(2).join(" ")} failed: #{error.strip}" unless status.success?
    end
  end
end
