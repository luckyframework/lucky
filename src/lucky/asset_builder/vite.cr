require "json"
require "./base"

module Lucky::AssetBuilder
  class Vite < Base
    @manifest_path : String

    def initialize(@manifest_path : String = "./public/.vite/manifest.json")
    end

    def manifest_path : String
      @manifest_path
    end

    def parse_manifest(manifest_content : String) : Hash(String, String)
      manifest = JSON.parse(manifest_content)
      result = {} of String => String

      # Check if this is a dev manifest (has "url" and "inputs" properties)
      if manifest["url"]? && manifest["inputs"]?
        # This is a dev manifest from vite-plugin-dev-manifest
        base_url = manifest["url"].as_s
        inputs = manifest["inputs"].as_h

        inputs.each do |_, value|
          # In dev mode, we store the full URL to the source file
          path = value.as_s
          # Remove src/ prefix to match Lucky's convention
          normalized_key = path.starts_with?("src/") ? path[4..] : path
          normalized_key = normalize_key(normalized_key)
          result[normalized_key] = base_url + path
        end
      else
        # This is a production manifest
        manifest.as_h.each do |key, value|
          # Skip chunks that start with underscore (these are shared chunks)
          next if key.starts_with?("_")

          # Only process entries that have a src property (actual source files)
          if value["src"]?
            # Use the src path as the key, stripping "src/" prefix
            src_path = value["src"].as_s
            normalized_key = src_path.starts_with?("src/") ? src_path[4..] : src_path
            normalized_key = normalize_key(normalized_key)

            # Get the output file path
            file_path = value["file"].as_s
            result[normalized_key] = "/#{file_path}"
          end
        end
      end

      result
    end
  end
end
