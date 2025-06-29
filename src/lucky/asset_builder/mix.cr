require "json"
require "./base"

module Lucky::AssetBuilder
  class Mix < Base
    @manifest_path : String
    
    def initialize(@manifest_path : String = "./public/mix-manifest.json")
    end
    
    def manifest_path : String
      @manifest_path
    end
    
    def parse_manifest(manifest_content : String) : Hash(String, String)
      manifest = JSON.parse(manifest_content)
      result = {} of String => String
      
      manifest.as_h.each do |key, value|
        normalized_key = normalize_key(key)
        result[normalized_key] = value.as_s
      end
      
      result
    end
  end
end