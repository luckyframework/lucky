module Lucky::AssetBuilder
  abstract class Base
    abstract def manifest_path : String
    abstract def parse_manifest(manifest_content : String) : Hash(String, String)

    def load_manifest : Hash(String, String)
      unless File.exists?(manifest_path)
        raise MissingManifestError.new(manifest_path)
      end

      manifest_content = File.read(manifest_path)
      parse_manifest(manifest_content)
    end

    def normalize_key(key : String) : String
      key.gsub(/^\//, "").gsub(/^assets\//, "")
    end
  end

  class MissingManifestError < Exception
    def initialize(path : String)
      super("Manifest at #{path} does not exist. Make sure you have compiled your assets.")
    end
  end
end
