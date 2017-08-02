require "colorize"
require "json"
require "levenshtein"

missing_asset = ARGV.first
manifest_path = File.expand_path("./public/manifest.json")
manifest_file = File.read(manifest_path)
manifest = JSON.parse(manifest_file)

best_match = Levenshtein::Finder.find missing_asset, manifest.map(&.to_s), tolerance: 4

puts %("#{missing_asset}" does not exist in the manifest).colorize(:red)

if best_match
  puts %(Did you mean "#{best_match}"?).colorize(:yellow)
else
  puts "Make sure the asset exists and you have compiled your assets".colorize(:red)
end

raise "There was a problem finding the asset"
