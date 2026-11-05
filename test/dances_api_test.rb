# frozen_string_literal: true

require "test_helper"

class DancesApiTest < ApiTestCase
  DANCE_URL = "/api/dances"
  PRESET = JSON.parse(File.read(File.expand_path("../build/assets/data/presets.json", __dir__))).first

  # A save as Backbone sends it: one of the frontend's presets (numbers and
  # booleans) plus the fields saveDanceView sets.
  def backbone_body(overrides = {})
    PRESET.merge(
      "guid" => nil,
      "uuid" => OWNER,
      "robot_id" => "3", # from sessionStorage, so a string
      "robot_name" => "Sir Wiggles Byte",
      "robot_still" => "",
      "sound_id" => 2,
      "rightUpperArm_reverse" => false
    ).merge(overrides)
  end

  def test_missing_or_unknown_guid_reports_dance_not_found
    ["#{DANCE_URL}/", DANCE_URL, "#{DANCE_URL}/doesnotexist1"].each do |path|
      get path
      assert_equal 200, last_response.status, path
      assert_equal({ "danceFound" => false }, json_response, path)
    end
  end

  def test_legacy_dance_matches_the_php_api_response
    insert_dance
    get "#{DANCE_URL}/#{LEGACY_GUID}"

    assert_equal 200, last_response.status
    assert_equal "application/json", last_response.media_type
    assert_equal "no-store", last_response.headers["cache-control"]

    expected = LEGACY_RESPONSE.merge("uuid" => nil) # hidden from anyone but the owner
    assert_equal [expected], json_response
    assert_equal expected.keys, json_response.first.keys, "key order should match the PHP API"
  end

  def test_owner_uuid_is_only_revealed_to_the_owner
    insert_dance

    get "#{DANCE_URL}/#{LEGACY_GUID}"
    assert_nil json_response.first["uuid"]

    visit_as SOMEONE_ELSE
    get "#{DANCE_URL}/#{LEGACY_GUID}"
    assert_nil json_response.first["uuid"]

    clear_cookies
    visit_as OWNER
    get "#{DANCE_URL}/#{LEGACY_GUID}"
    assert_equal OWNER, json_response.first["uuid"]
  end

  def test_soundtrack_follows_sound_id_and_defaults_to_electro
    insert_dance(guid: "pop0000000000", sound_id: 3)
    insert_dance(guid: "none000000000", sound_id: nil)

    get "#{DANCE_URL}/pop0000000000"
    assert_equal "/assets/music/loops/pop.ogg", json_response.first["soundtrack"]["ogg"]

    get "#{DANCE_URL}/none000000000"
    assert_nil json_response.first["sound_id"]
    assert_equal(
      {
        "mp3" => "/assets/music/loops/electro.mp3",
        "ogg" => "/assets/music/loops/electro.ogg",
        "wav" => "/assets/music/loops/electro.wav"
      },
      json_response.first["soundtrack"]
    )
  end

  def test_competition_flag_is_returned_as_a_string
    insert_dance(is_entered_into_comp: true)
    get "#{DANCE_URL}/#{LEGACY_GUID}"
    assert_equal "1", json_response.first["is_entered_into_comp"]
  end

  def test_creating_a_dance_returns_its_new_guid_and_stores_legacy_strings
    send_json :post, DANCE_URL, backbone_body

    assert_equal 200, last_response.status
    guid = json_response
    assert_match(/\A[0-9a-f]{13}\z/, guid)

    dance = find_dance(guid)
    assert_equal OWNER, dance[:owner_uuid]
    assert_equal 3, dance[:robot_id]
    assert_equal 2, dance[:sound_id]

    visit_as OWNER
    get "#{DANCE_URL}/#{guid}"
    saved = json_response.first
    assert_equal RoboBoogie::LegacyFormat::MOVE_KEYS, saved.keys.first(23)
    assert_equal "1", saved["masterTempo"]
    assert_equal "11.4", saved["neck_upDown"]
    assert_equal "1", saved["rightForearm_reverse"], "true is stored as \"1\""
    assert_equal "1", saved["leftForearm_reverse"], "1 is stored as \"1\""
    assert_equal "", saved["rightUpperArm_reverse"], "false is stored as \"\""
    assert_equal "Sir Wiggles Byte", saved["robot_name"]
    assert_equal OWNER, saved["uuid"]
    assert_equal "0", saved["is_entered_into_comp"]
  end

  def test_unknown_robot_or_sound_ids_are_stored_as_null
    send_json :post, DANCE_URL, backbone_body("robot_id" => "99", "sound_id" => 7)

    dance = find_dance(json_response)
    assert_nil dance[:robot_id]
    assert_nil dance[:sound_id]
  end

  def test_creating_requires_a_valid_uuid
    [nil, "", "not a uuid!", 12_345_678].each do |uuid|
      send_json :post, DANCE_URL, backbone_body("uuid" => uuid)
      assert_equal 422, last_response.status, uuid.inspect
    end
    assert_equal 0, RoboBoogie.db[:dances].count
  end

  def test_posting_an_unknown_guid_creates_a_new_dance
    send_json :post, DANCE_URL, backbone_body("guid" => "doesnotexist1")

    assert_equal 200, last_response.status
    refute_equal "doesnotexist1", json_response
    assert find_dance(json_response)
  end

  def test_owner_can_update_their_dance
    insert_dance
    body = backbone_body(
      "guid" => LEGACY_GUID,
      "robot_id" => "5",
      "sound_id" => 4,
      "robot_name" => "Captain Renamed",
      "masterTempo" => 2,
      "is_entered_into_comp" => "1"
    )
    send_json :put, "#{DANCE_URL}/#{LEGACY_GUID}", body

    assert_equal 200, last_response.status
    assert_equal LEGACY_GUID, json_response

    dance = find_dance(LEGACY_GUID)
    assert_equal "Captain Renamed", dance[:robot_name]
    assert_equal 4, dance[:sound_id]
    assert_equal 1, dance[:robot_id], "updates never change the robot"
    assert dance[:is_entered_into_comp]
    assert_equal "2", JSON.parse(dance[:move])["masterTempo"]
  end

  def test_an_invalid_sound_id_leaves_the_soundtrack_alone_on_update
    insert_dance(sound_id: 3)
    send_json :put, "#{DANCE_URL}/#{LEGACY_GUID}", backbone_body("guid" => LEGACY_GUID, "sound_id" => 99)

    assert_equal 200, last_response.status
    assert_equal 3, find_dance(LEGACY_GUID)[:sound_id]
  end

  def test_other_people_cannot_overwrite_a_dance
    insert_dance

    [:put, :post].each do |verb|
      body = backbone_body("guid" => LEGACY_GUID, "uuid" => SOMEONE_ELSE, "robot_name" => "Vandalised")
      send_json verb, "#{DANCE_URL}/#{LEGACY_GUID}", body
      assert_equal 403, last_response.status, verb
    end

    send_json :put, "#{DANCE_URL}/#{LEGACY_GUID}", backbone_body("guid" => LEGACY_GUID, "uuid" => nil)
    assert_equal 403, last_response.status

    assert_equal "Lieutenant Jigalot Code", find_dance(LEGACY_GUID)[:robot_name]
  end

  def test_dances_without_an_owner_cannot_be_updated
    insert_dance(owner_uuid: nil)
    send_json :put, "#{DANCE_URL}/#{LEGACY_GUID}", backbone_body("guid" => LEGACY_GUID)

    assert_equal 403, last_response.status
  end

  def test_form_encoded_saves_are_accepted
    post DANCE_URL, { "uuid" => OWNER, "robot_id" => "2", "masterTempo" => "1.5" }

    assert_equal 200, last_response.status
    dance = find_dance(json_response)
    assert_equal 2, dance[:robot_id]
    assert_equal "1.5", JSON.parse(dance[:move])["masterTempo"]
  end

  def test_malformed_bodies_are_rejected
    put "#{DANCE_URL}/#{LEGACY_GUID}", "{not json", "CONTENT_TYPE" => "application/json"
    assert_equal 400, last_response.status

    put "#{DANCE_URL}/#{LEGACY_GUID}", "[1, 2]", "CONTENT_TYPE" => "application/json"
    assert_equal 400, last_response.status
  end

  def test_oversized_bodies_are_rejected
    send_json :post, DANCE_URL, backbone_body("robot_still" => "x" * 70_000)

    assert_equal 413, last_response.status
    assert_equal 0, RoboBoogie.db[:dances].count
  end

  # The cookie only decides what GET reveals; it never authorises a write, so a
  # cross-site request from the owner's browser can't change their dance.
  def test_the_owner_cookie_alone_does_not_authorise_updates
    insert_dance
    visit_as OWNER

    send_json :put, "#{DANCE_URL}/#{LEGACY_GUID}", backbone_body("guid" => LEGACY_GUID, "uuid" => nil)
    assert_equal 403, last_response.status

    send_json :put, "#{DANCE_URL}/#{LEGACY_GUID}", backbone_body("guid" => LEGACY_GUID, "uuid" => SOMEONE_ELSE)
    assert_equal 403, last_response.status
  end

  def test_same_origin_saves_work_whatever_origin_header_the_browser_sends
    ["http://example.org", "null"].each do |origin|
      send_json :post, DANCE_URL, backbone_body, "HTTP_ORIGIN" => origin
      assert_equal 200, last_response.status, origin
    end
  end
end
