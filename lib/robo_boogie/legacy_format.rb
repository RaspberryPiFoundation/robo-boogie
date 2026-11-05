# frozen_string_literal: true

require "json"
require "rack/utils"

module RoboBoogie
  # The JSON shapes the 2013 Backbone frontend expects, as produced by the
  # original CodeIgniter API. The frontend in build/ is served unchanged, so
  # these are a contract: move values are strings ("1", "", "2.6"), robot and
  # sound ids are integers, and is_entered_into_comp is "0" or "1".
  module LegacyFormat
    # The dance-move parameters, in the order the PHP API stored them.
    MOVE_KEYS = %w[
      masterTempo
      neck_tempoMultiplier neck_upDown neck_leftRight
      rightForearm_reverse rightForearm_tempoMultiplier rightForearm_amount rightForearm_angle
      rightUpperArm_reverse rightUpperArm_tempoMultiplier rightUpperArm_amount rightUpperArm_angle
      leftForearm_reverse leftForearm_tempoMultiplier leftForearm_amount leftForearm_angle
      leftUpperArm_reverse leftUpperArm_tempoMultiplier leftUpperArm_amount leftUpperArm_angle
      hips_tempoMultiplier hips_upDown hips_leftRight
    ].freeze

    # sound_id => loop file name. Like the PHP API, anything else plays electro.
    SOUNDTRACK_FILES = { 1 => "electro", 2 => "funk", 3 => "pop", 4 => "rock" }.freeze
    DEFAULT_SOUNDTRACK = "electro"
    SOUNDTRACK_FORMATS = %w[mp3 ogg wav].freeze

    # Robots are defined by the frontend's data file, so new robots work without API changes.
    ROBOTS_JSON = File.expand_path("../../build/assets/data/robots.json", __dir__)
    ROBOT_IDS = JSON.parse(File.read(ROBOTS_JSON)).map { |robot| robot.fetch("id") }.freeze

    ROBOT_NAME_MAX_LENGTH = 255

    module_function

    # A dance as returned by GET /api/dances/:guid (wrapped in an array by the
    # caller). The owner's UUID is only revealed to the owner: the frontend
    # compares it with its own UUID to decide whether to offer editing.
    def dance_response(dance, viewer_uuid: nil)
      soundtrack = SOUNDTRACK_FILES.fetch(dance[:sound_id], DEFAULT_SOUNDTRACK)

      parse_move(dance[:move]).merge(
        "sound_id" => dance[:sound_id],
        "robot_id" => dance[:robot_id],
        "robot_name" => dance[:robot_name],
        "robot_still" => "",
        "uuid" => owner?(dance, viewer_uuid) ? dance[:owner_uuid] : nil,
        "is_entered_into_comp" => dance[:is_entered_into_comp] ? "1" : "0",
        "danceFound" => true,
        "soundtrack" => SOUNDTRACK_FORMATS.to_h { |ext| [ext, "/assets/music/loops/#{soundtrack}.#{ext}"] }
      )
    end

    # An entry in the users endpoint's "dances" list, which the robot chooser
    # uses to offer "Edit saved dance" (matching robot_id strictly, so it must
    # stay an integer).
    def user_dance(dance)
      { "guid" => dance[:guid], "robot_id" => dance[:robot_id], "robot_name" => dance[:robot_name] }
    end

    def owner?(dance, uuid)
      owner = dance[:owner_uuid]
      !owner.nil? && !uuid.nil? && Rack::Utils.secure_compare(owner, uuid.to_s)
    end

    # The stored move: every MOVE_KEY, in order, as a legacy string value.
    def move_json(params)
      JSON.generate(MOVE_KEYS.to_h { |key| [key, legacy_string(params[key])] })
    end

    # PHP stored every posted value as a string; the frontend has only ever read
    # strings back, so new saves are normalised the same way.
    def legacy_string(value)
      case value
      when String then value
      when true then "1"
      when Integer then value.to_s
      when Float then value.finite? && value == value.truncate ? value.to_i.to_s : value.to_s
      else "" # false, nil, and anything structured
      end
    end

    def robot_name(value)
      legacy_string(value)[0, ROBOT_NAME_MAX_LENGTH]
    end

    def robot_id(value)
      known_id(value, ROBOT_IDS)
    end

    def sound_id(value)
      known_id(value, SOUNDTRACK_FILES.keys)
    end

    # PHP compared with `== 1`.
    def flag?(value)
      [true, 1, "1"].include?(value)
    end

    def known_id(value, ids)
      id = Integer(value.to_s, 10, exception: false)
      ids.include?(id) ? id : nil
    end

    def parse_move(raw)
      move = raw.is_a?(String) ? JSON.parse(raw) : raw
      move.is_a?(Hash) ? move : {}
    rescue JSON::ParserError
      {}
    end
  end
end
