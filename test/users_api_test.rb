# frozen_string_literal: true

require "test_helper"

class UsersApiTest < ApiTestCase
  USER_URL = "/api/index.php/users/user"

  def test_page_load_echoes_the_uuid_and_sets_the_owner_cookie
    visit_as OWNER

    assert_equal 200, last_response.status
    assert_equal({ "uuid" => OWNER, "dances" => [] }, json_response)

    cookie = last_response.headers["set-cookie"]
    assert_includes cookie, "rb_owner=#{OWNER}"
    assert_match(%r{path=/api(;|\z)}i, cookie)
    assert_match(/max-age=31536000/i, cookie)
    assert_match(/httponly/i, cookie)
    assert_match(/samesite=lax/i, cookie)
    refute_match(/secure/i, cookie, "plain-HTTP requests (local dev) get a non-Secure cookie")
  end

  def test_owner_cookie_is_secure_over_https
    get "https://example.org#{USER_URL}/#{OWNER}", uuid: OWNER
    assert_match(/secure/i, last_response.headers["set-cookie"])
  end

  def test_first_visit_registration_with_put
    send_json :put, "#{USER_URL}/#{OWNER}", { "uuid" => OWNER }

    assert_equal 200, last_response.status
    assert_equal OWNER, json_response["uuid"]
    assert_includes last_response.headers["set-cookie"], "rb_owner=#{OWNER}"
  end

  def test_matches_the_php_api_response_for_the_legacy_example
    insert_dance
    visit_as OWNER

    expected = {
      "uuid" => OWNER,
      "dances" => [{ "guid" => LEGACY_GUID, "robot_id" => 1, "robot_name" => "Lieutenant Jigalot Code" }]
    }
    assert_equal expected, json_response
  end

  # The robot chooser keeps the last dance per robot, so oldest-first matters.
  def test_lists_only_this_users_dances_oldest_first
    insert_dance(guid: "a000000000001", robot_id: 2, robot_name: "First")
    insert_dance(guid: "b000000000001", owner_uuid: SOMEONE_ELSE)
    insert_dance(guid: "a000000000002", robot_id: 5, robot_name: "Second")
    visit_as OWNER

    assert_equal(
      [
        { "guid" => "a000000000001", "robot_id" => 2, "robot_name" => "First" },
        { "guid" => "a000000000002", "robot_id" => 5, "robot_name" => "Second" }
      ],
      json_response["dances"]
    )
  end

  def test_invalid_uuids_are_echoed_without_a_cookie
    get "#{USER_URL}/", uuid: "bad uuid!"
    assert_equal({ "uuid" => "bad uuid!", "dances" => [] }, json_response)
    assert_nil last_response.headers["set-cookie"]

    get "#{USER_URL}/"
    assert_equal({ "uuid" => false, "dances" => [] }, json_response)
  end
end
