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

    puts <<-ASSET_MACRO
    macro asset(path)
      {% if ASSET_MANIFEST[path] %}
        {{ ASSET_MANIFEST[path] }}
      {% else %}
        {% raise "\#{path} does not exist in the manifest.\n Make sure webpack is running and the asset exists." %}
      {% end %}
    end
    ASSET_MACRO
  else
    puts "Manifest at #{manifest_path} does not exist".colorize(:red)
    puts "Make sure you have run webpack".colorize(:red)
    raise "Error generating asset helpers"
  end
rescue ex
  puts ex.message.colorize(:red)
  raise ex
end
