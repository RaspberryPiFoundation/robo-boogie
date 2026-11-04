# frozen_string_literal: true

require "test_helper"

class StaticTest < ApiTestCase
  def test_home_page_serves_the_frontend_and_can_be_framed
    get "/"

    assert_equal 200, last_response.status
    assert_equal "text/html", last_response.media_type
    assert_equal "no-cache", last_response.headers["cache-control"]
    assert_includes last_response.body, "assets/js/roboboogie.min.js"
    assert_includes last_response.body, "G-5LEKLKMJHE"
    refute_includes last_response.body, "UA-30750176-1"
    assert_nil last_response.headers["x-frame-options"], "#iframe/ embeds on other sites must keep working"
  end

  def test_no_server_side_source_is_served
    ["/api/index.php", "/api/application/config/database.php"].each do |path|
      get path
      assert_equal 404, last_response.status, path
    end
  end

  def test_assets_are_served_with_a_day_of_caching
    get "/assets/data/robots.json"

    assert_equal 200, last_response.status
    assert_equal "public, max-age=86400", last_response.headers["cache-control"]
    assert_equal 7, JSON.parse(last_response.body).length
  end
end
