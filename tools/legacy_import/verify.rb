# frozen_string_literal: true

# Compares dances served by the legacy PHP API with the new app, after an
# import. Run it before switching DNS, while the legacy API is still live.
#
#   bundle exec ruby tools/legacy_import/verify.rb \
#     --legacy https://roboboogie.codeclub.org.uk --new https://APP.herokuapp.com \
#     --report legacy-import-report.json --database-url URL
#
# See README.md in this directory.

require "json"
require "net/http"
require "optparse"
require "sequel"

options = { sample: 200, owners: 50, report: "legacy-import-report.json" }
parser = OptionParser.new do |opts|
  opts.banner = "Usage: bundle exec ruby #{$PROGRAM_NAME} --legacy URL --new URL [options]"
  opts.on("--legacy URL", "The legacy site, e.g. https://roboboogie.codeclub.org.uk") { |url| options[:legacy] = url }
  opts.on("--new URL", "The new app, e.g. https://APP.herokuapp.com") { |url| options[:new] = url }
  opts.on("--report PATH", "Report from import.rb (default: #{options[:report]})") { |path| options[:report] = path }
  opts.on("--sample N", Integer, "Random imported dances to compare (default: #{options[:sample]})") { |n| options[:sample] = n }
  opts.on("--guids A,B", Array, "Compare these dances instead of the report's") { |guids| options[:guids] = guids }
  opts.on("--database-url URL", "The imported Postgres, to look up owners for the users check") { |url| options[:database_url] = url }
  opts.on("--owners N", Integer, "Owners whose dance lists to compare (default: #{options[:owners]})") { |n| options[:owners] = n }
end
parser.parse!
abort parser.help unless options[:legacy] && options[:new]

# Keeps one connection per site open between requests.
class Site
  HEADERS = { "User-Agent" => "roboboogie-legacy-verify", "Accept" => "application/json" }.freeze

  def initialize(base_url, pause: 0)
    @uri = URI(base_url)
    @pause = pause
    @http = Net::HTTP.start(@uri.host, @uri.port, use_ssl: @uri.scheme == "https", open_timeout: 10, read_timeout: 30)
  end

  def get_json(path)
    sleep @pause
    response = @http.get(path, HEADERS)
    return "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue JSON::ParserError
    "not JSON: #{response.body[0, 80].inspect}"
  end
end

# The owner UUID is hidden by the new app (it's only shown to the owner), and
# robot_still images were dropped, so neither is compared.
def normalise_dance(body)
  return body unless body.is_a?(Array) && body.first.is_a?(Hash)

  body.first.except("uuid", "robot_still")
end

def differences(legacy, new)
  return [] if legacy == new && (!legacy.is_a?(Hash) || legacy.keys == new.keys)
  return ["legacy #{legacy.inspect[0, 120]}", "new    #{new.inspect[0, 120]}"] unless legacy.is_a?(Hash) && new.is_a?(Hash)

  changed = (legacy.keys | new.keys).reject { |key| legacy[key] == new[key] }
  lines = changed.first(5).map { |key| "#{key}: legacy #{legacy[key].inspect} / new #{new[key].inspect}" }
  lines << "keys in a different order" if changed.empty? && legacy.keys != new.keys
  lines
end

def compare(label, items, legacy_site, new_site)
  failures = items.filter_map do |item, path|
    legacy = yield legacy_site.get_json(path)
    new = yield new_site.get_json(path)
    diff = differences(legacy, new)
    [item, diff] unless diff.empty?
  end

  puts "#{label}: compared #{items.length}, #{items.length - failures.length} identical, #{failures.length} different"
  failures.first(20).each do |item, diff|
    puts "  #{item}"
    diff.each { |line| puts "      #{line}" }
  end
  puts "  (and #{failures.length - 20} more)" if failures.length > 20
  failures.empty?
end

report = JSON.parse(File.read(options[:report])) if File.file?(options[:report])
abort "No import report at #{options[:report]}: pass --report or --guids" unless report || options[:guids]

guids = options[:guids] || begin
  edge_cases = report["issues"].reject { |issue| issue["issue"] == "missing_guid" }.flat_map { |issue| issue["examples"] }
  (report["sample_guids"].sample(options[:sample]) + edge_cases).uniq
end

legacy_site = Site.new(options[:legacy], pause: 0.05) # go gently on the old VM
new_site = Site.new(options[:new])

dance_paths = guids.map { |guid| [guid, "/api/index.php/dances/dance/#{URI.encode_uri_component(guid)}"] }
ok = compare("Dances", dance_paths, legacy_site, new_site) { |body| normalise_dance(body) }

if options[:database_url] && report
  # Only owners of imported legacy dances: asking the legacy API about a UUID
  # it doesn't know would create a user row there.
  owners = Sequel.connect(options[:database_url]) do |db|
    db[:dances].where(guid: guids).where { id <= report.fetch("highest_legacy_id") }
               .exclude(owner_uuid: nil).distinct.select_map(:owner_uuid).first(options[:owners])
  end
  owner_paths = owners.map.with_index(1) do |uuid, n|
    ["owner #{n}", "/api/index.php/users/user/#{uuid}?uuid=#{uuid}"]
  end
  ok = compare("Owners' dance lists", owner_paths, legacy_site, new_site) do |body|
    body.is_a?(Hash) ? body.merge("dances" => Array(body["dances"]).sort_by { |dance| dance["guid"].to_s }) : body
  end && ok
else
  puts "Owners' dance lists: skipped (needs --database-url and the import report)"
end

exit(ok ? 0 : 1)
