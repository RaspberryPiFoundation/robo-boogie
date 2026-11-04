# frozen_string_literal: true

require "test_helper"
require_relative "../tools/legacy_import/legacy_import"

class LegacyImportTest < ApiTestCase
  DANCE_URL = "/api/index.php/dances/dance"

  # A row as LegacyImport::EXPORT_SQL produces it, for the live example dance.
  def export_row(overrides = {})
    {
      "id" => 101,
      "guid" => LEGACY_GUID,
      "robot_name" => "Lieutenant Jigalot Code",
      "move" => JSON.generate(LEGACY_RESPONSE.slice(*RoboBoogie::LegacyFormat::MOVE_KEYS)),
      "is_entered_into_comp" => 0,
      "date_created" => 1_793_749_420,
      "date_updated" => 1_793_749_420,
      "robot_id" => 1,
      "robot_links" => 1,
      "sound_id" => 1,
      "sound_links" => 1,
      "owner_uuid" => OWNER,
      "owner_links" => 1
    }.merge(overrides)
  end

  def import(rows, transformer: LegacyImport::Transformer.new)
    loader = LegacyImport::Loader.new(RoboBoogie.db)
    loader.load(rows.filter_map { |row| transformer.call(row) })
    loader
  end

  def test_imported_dances_are_served_exactly_as_the_php_api_served_them
    import [export_row]

    get "#{DANCE_URL}/#{LEGACY_GUID}"
    assert_equal [LEGACY_RESPONSE.merge("uuid" => nil)], json_response
    assert_equal LEGACY_RESPONSE.keys, json_response.first.keys

    visit_as OWNER
    expected = [{ "guid" => LEGACY_GUID, "robot_id" => 1, "robot_name" => "Lieutenant Jigalot Code" }]
    assert_equal expected, json_response["dances"]
  end

  def test_unusual_rows_are_reported_and_handled_like_the_php_api
    transformer = LegacyImport::Transformer.new
    import(
      [
        export_row,
        export_row("id" => 102, "guid" => nil),
        export_row("id" => 103, "robot_name" => "Duplicate"),
        export_row("id" => 104, "guid" => "broken0000001", "move" => "not json{", "owner_uuid" => nil, "owner_links" => 0),
        export_row(
          "id" => 105, "guid" => "linked0000001", "robot_name" => "Señor",
          "robot_id" => nil, "robot_links" => 2, "sound_id" => nil, "sound_links" => 0,
          "date_created" => nil, "date_updated" => nil
        )
      ],
      transformer: transformer
    )

    counts = transformer.report[:issues].to_h { |issue| [issue[:issue], issue[:count]] }
    expected = {
      missing_guid: 1, duplicate_guid: 1, invalid_move: 1, no_owner: 1, no_robot: 1,
      several_robots: 1, no_soundtrack: 1, no_timestamps: 1, non_ascii_name: 1
    }
    assert_equal expected, counts
    assert_equal [5, 3], [transformer.rows_read, transformer.rows_kept]

    assert_equal "Lieutenant Jigalot Code", find_dance(LEGACY_GUID)[:robot_name], "a duplicate guid keeps the lowest id"
    assert_equal "{}", find_dance("broken0000001")[:move]
    linked = find_dance("linked0000001")
    assert_equal "Señor", linked[:robot_name]
    assert_equal Time.at(0), linked[:created_at]
  end

  def test_reimporting_only_applies_newer_changes
    import [export_row]

    import [export_row("robot_name" => "Older", "date_updated" => 1_793_749_000)]
    assert_equal "Lieutenant Jigalot Code", find_dance(LEGACY_GUID)[:robot_name]

    import [export_row("robot_name" => "Newer", "date_updated" => 1_793_749_999)]
    assert_equal "Newer", find_dance(LEGACY_GUID)[:robot_name]
    assert_equal 1, RoboBoogie.db[:dances].count
  end

  def test_reimporting_keeps_edits_made_on_the_new_app
    import [export_row]
    send_json :put, "#{DANCE_URL}/#{LEGACY_GUID}", { "guid" => LEGACY_GUID, "uuid" => OWNER, "robot_name" => "Edited" }
    assert_equal 200, last_response.status

    import [export_row]
    assert_equal "Edited", find_dance(LEGACY_GUID)[:robot_name]
  end

  def test_new_dances_get_ids_well_clear_of_legacy_ones
    import [export_row("id" => 4321)]
    send_json :post, DANCE_URL, { "uuid" => OWNER, "robot_id" => 1 }
    assert_equal 4321 + LegacyImport::Loader::ID_GAP, find_dance(json_response)[:id]

    # Dances saved on the old server during cutover keep their own ids.
    import [export_row("id" => 4322, "guid" => "straggler0001")]
    assert_equal 4322, find_dance("straggler0001")[:id]
  end

  def test_an_id_clash_explains_what_to_do
    insert_dance(id: 101, guid: "savedonheroku")

    error = assert_raises(Sequel::UniqueConstraintViolation) { import [export_row] }
    assert_match(/saved on the new app before the first import/, error.message)
    assert_nil find_dance(LEGACY_GUID), "nothing is imported when the batch fails"
  end

  def test_the_sample_for_verify_is_capped_and_unique
    transformer = LegacyImport::Transformer.new(random: Random.new(1))
    1_500.times { |n| transformer.call(export_row("id" => n, "guid" => format("guid%09d", n))) }

    assert_equal LegacyImport::SAMPLE_SIZE, transformer.sample.length
    assert_equal transformer.sample.uniq, transformer.sample
  end
end
