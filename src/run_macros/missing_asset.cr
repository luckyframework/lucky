require "colorize"
require "json"

asset = ARGV.first

puts "#{asset} does not exist in the manifest.".colorize(:red)
puts "Make sure webpack is running and the asset exists.".colorize(:red)

raise "There was a problem finding the asset"
