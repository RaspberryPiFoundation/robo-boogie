# frozen_string_literal: true

ENV["APP_ENV"] = ENV["RACK_ENV"] = "test"

test_database_url = ENV.fetch("TEST_DATABASE_URL") do
  abort "Set TEST_DATABASE_URL to a disposable Postgres database, e.g. TEST_DATABASE_URL=postgres:///roboboogie_test"
end
abort "TEST_DATABASE_URL must differ from DATABASE_URL: the tests wipe it" if test_database_url == ENV["DATABASE_URL"]
ENV["DATABASE_URL"] = test_database_url

require "json"
require "minitest/autorun"
require "rack/test"
require_relative "../app"

Sequel.extension :migration
Sequel::Migrator.run(RoboBoogie.db, File.expand_path("../db/migrate", __dir__))

class ApiTestCase < Minitest::Test
  include Rack::Test::Methods

  OWNER = "11111111-2222-4333-8444-555555555555"
  SOMEONE_ELSE = "99999999-8888-4777-8666-555555555555"
  LEGACY_GUID = "6aea71ac6af51"

  # The live PHP API's response for GET /api/index.php/dances/dance/6aea71ac6af51,
  # captured in November 2026, with the owner's UUID replaced by OWNER.
  LEGACY_RESPONSE = JSON.parse(File.read(File.expand_path("fixtures/legacy_dance_response.json", __dir__))).first

  def app
    RoboBoogie::App
  end

  def setup
    RoboBoogie.db[:dances].truncate(restart: true)
  end

  def json_response
    JSON.parse(last_response.body)
  end

  def send_json(verb, path, body, env = {})
    send(verb, path, JSON.generate(body), { "CONTENT_TYPE" => "application/json" }.merge(env))
  end

  # A dance as imported from the PHP app: move is the JSON text the PHP API stored.
  def insert_dance(**attrs)
    legacy_move = JSON.generate(LEGACY_RESPONSE.slice(*RoboBoogie::LegacyFormat::MOVE_KEYS))
    RoboBoogie.db[:dances].insert(
      {
        guid: LEGACY_GUID,
        owner_uuid: OWNER,
        robot_id: 1,
        sound_id: 1,
        robot_name: "Lieutenant Jigalot Code",
        move: Sequel.cast(legacy_move, :json)
      }.merge(attrs)
    )
  end

  def find_dance(guid)
    RoboBoogie.db[:dances].where(guid: guid).first
  end

  # What the frontend does on every page load; this sets the owner cookie.
  def visit_as(uuid)
    get "/api/index.php/users/user/#{uuid}", uuid: uuid
  end
end
