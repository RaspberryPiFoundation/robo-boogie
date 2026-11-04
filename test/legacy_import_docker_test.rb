# frozen_string_literal: true

require "open3"
require "tmpdir"
require "test_helper"

# Runs tools/legacy_import/import.rb on a genuine MySQL 5.5 dump. Needs
# Docker, so it only runs with DOCKER_TESTS=1.
class LegacyImportDockerTest < ApiTestCase
  ROOT = File.expand_path("..", __dir__)

  def test_importing_a_real_mysql_5_5_dump
    skip "Set DOCKER_TESTS=1 to run (needs Docker)" unless ENV["DOCKER_TESTS"]

    report_path = File.join(Dir.tmpdir, "legacy-import-report-#{Process.pid}.json")
    output, status = Open3.capture2e(
      "bundle", "exec", "ruby", "tools/legacy_import/import.rb", "test/fixtures/legacy_dump.sql",
      "--database-url", ENV.fetch("DATABASE_URL"), "--report", report_path,
      chdir: ROOT
    )
    assert status.success?, output

    report = JSON.parse(File.read(report_path))
    assert_equal [12, 10], [report["rows_read"], report["rows_kept"]]
    assert_equal "Señor Groove Byte", find_dance("5281068541414")[:robot_name]
    assert_equal "Captain D'Artagnan \\ Slash", find_dance("5281029d56337")[:robot_name]

    get "/api/index.php/dances/dance/#{LEGACY_GUID}"
    assert_equal [LEGACY_RESPONSE.merge("uuid" => nil)], json_response
  ensure
    File.delete(report_path) if report_path && File.exist?(report_path)
  end
end
