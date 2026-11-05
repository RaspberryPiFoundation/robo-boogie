# frozen_string_literal: true

require "test_helper"
require_relative "../lib/robo_boogie/force_https"

class ForceHTTPSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    RoboBoogie::ForceHTTPS.new(->(_env) { [200, { "content-type" => "text/plain" }, ["ok"]] })
  end

  def test_redirects_plain_http_reads_to_https
    get "http://roboboogie.example/assets/data/robots.json?v=1"

    assert_equal 301, last_response.status
    assert_equal "https://roboboogie.example/assets/data/robots.json?v=1", last_response.headers["location"]
  end

  def test_rejects_plain_http_writes
    put "http://roboboogie.example/api/dances/abc"
    assert_equal 403, last_response.status
  end

  def test_passes_through_requests_forwarded_over_https
    get "/", {}, "HTTP_X_FORWARDED_PROTO" => "https"

    assert_equal 200, last_response.status
    assert_equal "ok", last_response.body
  end
end
