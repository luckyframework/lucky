class Lucky::AssetManifest
  INSTANCE      = new
  MANIFEST_PATH = File.expand_path(ENV["ASSET_MANIFEST_PATH"]? || "./public/mix-manifest.json")

  @_to_h : Hash(String, String)?

  def self.fingerpinted_path_for(path) : String?
    INSTANCE.to_h[path]?
  end

  def self.non_fingerprinted_paths : Array(String)
    INSTANCE.to_h.keys
  end

  # :nodoc:
  def to_h : Hash(String, String)
    @_to_h ||= begin
      manifest_file = File.read(MANIFEST_PATH)
      manifest = JSON.parse(manifest_file)

      manifest
        .as_h
        .transform_keys(&.gsub(/^\//, "").gsub(/^assets\//, ""))
        .transform_values(&.as_s)
    end
  end
end
