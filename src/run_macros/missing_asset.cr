require "colorize"
require "json"
require "levenshtein"

asset = ARGV.first
manifest_path = File.expand_path("./public/manifest.json")
manifest_file = File.read(manifest_path)
manifest = JSON.parse(manifest_file)

finder = Levenshtein::Finder.new asset
manifest.each do |asset_path, _|
  finder.test asset_path.as_s
end

puts "#{asset} does not exist in the manifest.".colorize(:red)
puts %(Did you mean "#{finder.best_match}"?).colorize(:yellow)

raise "There was a problem finding the asset"
