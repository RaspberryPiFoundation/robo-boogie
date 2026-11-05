# frozen_string_literal: true

require "test_helper"

class LegacyFormatTest < Minitest::Test
  LegacyFormat = RoboBoogie::LegacyFormat

  def test_values_are_stored_the_way_php_stored_them
    {
      "2.6" => "2.6",
      "" => "",
      true => "1",
      false => "",
      nil => "",
      1 => "1",
      2.0 => "2",
      0.25 => "0.25",
      [1] => "",
      { "a" => 1 } => ""
    }.each do |input, expected|
      assert_equal expected, LegacyFormat.legacy_string(input), input.inspect
    end
  end

  def test_move_json_has_every_key_in_legacy_order
    move = JSON.parse(LegacyFormat.move_json("masterTempo" => 1, "extra" => "ignored"))

    assert_equal LegacyFormat::MOVE_KEYS, move.keys
    assert_equal "1", move["masterTempo"]
    assert_equal "", move["hips_leftRight"]
  end

  def test_robot_ids_come_from_the_frontend_data
    assert_equal (1..7).to_a, LegacyFormat::ROBOT_IDS
    assert_equal 3, LegacyFormat.robot_id("3")
    assert_equal 3, LegacyFormat.robot_id(3)
    assert_nil LegacyFormat.robot_id("99")
    assert_nil LegacyFormat.robot_id("3.5")
    assert_nil LegacyFormat.robot_id(nil)
  end

  def test_flags_follow_phps_loose_comparison_with_one
    assert LegacyFormat.flag?(1)
    assert LegacyFormat.flag?("1")
    assert LegacyFormat.flag?(true)
    refute LegacyFormat.flag?("0")
    refute LegacyFormat.flag?(nil)
  end

  def test_robot_names_are_capped_at_the_legacy_column_size
    assert_equal 255, LegacyFormat.robot_name("x" * 300).length
  end

  def test_unreadable_moves_become_empty
    assert_equal({}, LegacyFormat.parse_move("{not json"))
    assert_equal({}, LegacyFormat.parse_move("[1]"))
    assert_equal({}, LegacyFormat.parse_move(nil))
  end
end
