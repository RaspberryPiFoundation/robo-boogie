# frozen_string_literal: true

require "json"
require "securerandom"
require "sinatra/base"
require_relative "lib/robo_boogie/db"
require_relative "lib/robo_boogie/legacy_format"

module RoboBoogie
  # Serves the static Backbone frontend from build/ and the small JSON API it
  # talks to. The API keeps the old CodeIgniter paths (/api/index.php/...) and
  # response shapes, so the frontend and every shared #watch/ and #iframe/ link
  # keep working unchanged. See docs/heroku-migration.md.
  class App < Sinatra::Base
    BUILD_DIR = File.expand_path("build", __dir__)

    DANCE_PATH = %r{/api/index\.php/dances/dance(?:/([^/]*))?/?}
    USER_PATH = %r{/api/index\.php/users/user(?:/([^/]*))?/?}

    # A "user" is a random UUID the frontend keeps in localStorage. The users
    # endpoint (called on every page load) stores it in this cookie, so dance
    # responses can reveal the owner's UUID to the owner and nobody else.
    OWNER_COOKIE = "rb_owner"
    OWNER_COOKIE_MAX_AGE = 365 * 24 * 60 * 60
    UUID_FORMAT = /\A[0-9A-Za-z-]{8,64}\z/

    MAX_BODY_BYTES = 64 * 1024
    GUID_ATTEMPTS = 5

    configure do
      set :public_folder, BUILD_DIR
      set :static_cache_control, [:public, { max_age: 86_400 }]
      # Dances are embedded on other sites through #iframe/ URLs, so don't send
      # X-Frame-Options. Cross-site request forgery isn't a concern: writes are
      # authorised by the owner's UUID in the request body, never by a cookie.
      set :protection, except: [:frame_options]
    end

    helpers do
      def dances
        RoboBoogie.db[:dances]
      end

      def json(data, status_code = 200)
        status status_code
        content_type :json
        JSON.generate(data)
      end

      def halt_json(status_code, message)
        halt json({ "error" => message }, status_code)
      end

      def presence(value)
        value if value.is_a?(String) && !value.empty?
      end

      def valid_uuid?(uuid)
        uuid.is_a?(String) && UUID_FORMAT.match?(uuid)
      end

      # Query string merged with the request body. Backbone sends JSON; the old
      # API also accepted form-encoded bodies, so those work too.
      def payload
        @payload ||= request.GET.merge(request.media_type == "application/json" ? json_body : request.POST)
      end

      def json_body
        halt_json 413, "Request body too large" if request.content_length.to_i > MAX_BODY_BYTES
        raw = read_body(MAX_BODY_BYTES + 1)
        halt_json 413, "Request body too large" if raw.bytesize > MAX_BODY_BYTES
        return {} if raw.strip.empty?

        data = JSON.parse(raw)
        halt_json 400, "Request body must be a JSON object" unless data.is_a?(Hash)
        data
      rescue JSON::ParserError
        halt_json 400, "Request body is not valid JSON"
      end

      # rack.input is optional in Rack 3 (e.g. on GET requests).
      def read_body(limit)
        input = request.body
        return "" unless input

        input.rewind if input.respond_to?(:rewind)
        input.read(limit).to_s
      end

      def remember_owner(uuid)
        response.set_cookie(
          OWNER_COOKIE,
          value: uuid,
          path: "/api",
          max_age: OWNER_COOKIE_MAX_AGE.to_s,
          httponly: true,
          same_site: :lax,
          secure: request.ssl?
        )
      end

      def dance_attributes
        {
          move: Sequel.cast(LegacyFormat.move_json(payload), :json),
          robot_name: LegacyFormat.robot_name(payload["robot_name"]),
          is_entered_into_comp: LegacyFormat.flag?(payload["is_entered_into_comp"])
        }
      end

      # Like the PHP API, an update leaves robot_id alone and only changes the
      # soundtrack when given a valid one.
      def update_dance(dance, uuid)
        halt_json 403, "This dance belongs to someone else" unless LegacyFormat.owner?(dance, uuid)

        changes = dance_attributes.merge(updated_at: Sequel::CURRENT_TIMESTAMP)
        sound_id = LegacyFormat.sound_id(payload["sound_id"])
        changes[:sound_id] = sound_id if sound_id
        dances.where(id: dance[:id]).update(changes)
        dance[:guid]
      end

      # New guids keep the legacy look (13 hex characters) but are random
      # rather than derived from the clock.
      def create_dance(uuid)
        halt_json 422, "A valid uuid is required to save a dance" unless valid_uuid?(uuid)

        row = dance_attributes.merge(
          owner_uuid: uuid,
          robot_id: LegacyFormat.robot_id(payload["robot_id"]),
          sound_id: LegacyFormat.sound_id(payload["sound_id"])
        )
        GUID_ATTEMPTS.times do
          guid = SecureRandom.hex(7)[0, 13]
          dances.insert(row.merge(guid: guid))
          return guid
        rescue Sequel::UniqueConstraintViolation
          next
        end
        raise "Couldn't generate a unique dance guid after #{GUID_ATTEMPTS} attempts"
      end
    end

    get "/" do
      cache_control :no_cache
      send_file File.join(BUILD_DIR, "index.html")
    end

    # Registers (GET on page load, PUT on first visit) and describes a user.
    # There is no users table: a user is simply the owner_uuid on their dances.
    [:get, :put, :post].each do |verb|
      send(verb, USER_PATH) do |path_uuid|
        cache_control :no_store
        uuid = presence(payload["uuid"]) || presence(path_uuid)

        if valid_uuid?(uuid)
          remember_owner(uuid)
          owned = dances.where(owner_uuid: uuid).order(:id).select(:guid, :robot_id, :robot_name)
          json("uuid" => uuid, "dances" => owned.map { |dance| LegacyFormat.user_dance(dance) })
        else
          json("uuid" => uuid || false, "dances" => [])
        end
      end
    end

    # The frontend fetches this with no guid when starting a new dance, and
    # expects {"danceFound": false} (an object, not an array) back.
    get DANCE_PATH do |guid|
      cache_control :no_store
      dance = presence(guid) && dances.where(guid: guid).first

      if dance
        json [LegacyFormat.dance_response(dance, viewer_uuid: request.cookies[OWNER_COOKIE])]
      else
        json("danceFound" => false)
      end
    end

    # Saves a dance and returns its guid as a JSON string. An existing guid is
    # updated (owner only); otherwise a new dance is created.
    [:post, :put].each do |verb|
      send(verb, DANCE_PATH) do |path_guid|
        cache_control :no_store
        uuid = payload["uuid"]
        guid = presence(payload["guid"]) || presence(path_guid)
        dance = guid && dances.where(guid: guid).first

        json(dance ? update_dance(dance, uuid) : create_dance(uuid))
      end
    end
  end
end
