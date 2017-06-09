require "json"
require "colorize"

begin
  manifest_path = File.expand_path("./public/manifest.json")

  if File.exists?(manifest_path)
    manifest_file = File.read(manifest_path)
    manifest = JSON.parse(manifest_file)

    manifest.each do |key, value|
      puts %({% ASSET_MANIFEST["#{key.as_s}"] = "#{value.as_s}" %})
    end

    puts "macro asset(path)"
    puts "  {{ ASSET_MANIFEST[path] }}"
    puts "end"
  else
    puts "Manifest at #{manifest_path} does not exist".colorize(:red)
    puts "Make sure you have run webpack".colorize(:red)
    raise "Error generating asset helpers"
  end
rescue ex
  puts ex.message.colorize(:red)
  raise ex
end
