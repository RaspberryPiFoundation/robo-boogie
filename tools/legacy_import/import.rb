# frozen_string_literal: true

# Imports dances from a mysqldump of the legacy MySQL database into Postgres.
#
#   bundle exec ruby tools/legacy_import/import.rb DUMP.sql[.gz] --database-url URL
#
# See README.md in this directory.

require "optparse"
require "uri"
require_relative "legacy_import"

options = { report: "legacy-import-report.json" }
parser = OptionParser.new do |opts|
  opts.banner = "Usage: bundle exec ruby #{$PROGRAM_NAME} DUMP.sql[.gz] --database-url URL [--report PATH]"
  opts.on("--database-url URL", "Postgres to import into (local, or `heroku config:get DATABASE_URL`)") do |url|
    options[:database_url] = url
  end
  opts.on("--report PATH", "Where to write the JSON report verify.rb reads (default: #{options[:report]})") do |path|
    options[:report] = path
  end
end
parser.parse!

dump_path = ARGV.shift
abort parser.help unless dump_path && options[:database_url]
abort "No such file: #{dump_path}" unless File.file?(dump_path)

def elapsed(started) = format("%.1fs", Process.clock_gettime(Process::CLOCK_MONOTONIC) - started)

def say(message) = $stderr.puts(message)

target = URI(options[:database_url])
say "Importing #{dump_path} into #{target.host || "localhost"}#{target.path}"

db = Sequel.connect(options[:database_url])
Sequel.extension :migration
Sequel::Migrator.run(db, File.expand_path("../../db/migrate", __dir__))
before_count = db[:dances].count

transformer = LegacyImport::Transformer.new
loader = LegacyImport::Loader.new(db)

LegacyImport::MySQLContainer.open do |mysql|
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  say "Restoring the dump into a temporary MySQL..."
  mysql.restore(dump_path)
  say "  done in #{elapsed(started)}"

  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  say "Copying dances into Postgres..."
  rows = Enumerator.new do |yielder|
    mysql.each_export_row(mysql.dances_database) do |row|
      attributes = transformer.call(row)
      yielder << attributes if attributes
    end
  end
  loader.load(rows)
  say "  done in #{elapsed(started)}"
end

report = transformer.report.merge(
  imported_at: Time.now.utc.iso8601,
  dump: File.basename(dump_path),
  dances_before: before_count,
  dances_after: db[:dances].count,
  highest_legacy_id: loader.legacy_max_id,
  table_size: db.get(Sequel.function(:pg_size_pretty, Sequel.function(:pg_total_relation_size, "dances"))),
  database_size: db.get(Sequel.function(:pg_size_pretty, Sequel.function(:pg_database_size, Sequel.function(:current_database))))
)
File.write(options[:report], JSON.pretty_generate(report))

say ""
say "Read #{report[:rows_read]} legacy dances, kept #{report[:rows_kept]}."
say "Postgres now has #{report[:dances_after]} dances (was #{report[:dances_before]}); " \
    "dances table #{report[:table_size]}, database #{report[:database_size]}."
if report[:issues].empty?
  say "No unusual rows."
else
  say "Unusual rows:"
  report[:issues].each do |issue|
    say format("  %6d  %s", issue[:count], issue[:meaning])
    say "          e.g. #{issue[:examples].first(3).join(", ")}"
  end
end
say "Report written to #{options[:report]}"
