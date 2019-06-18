module Lucky::AssetHelpers
  FINGERPINTED_ASSET_MAP = {} of String => String

  macro load_manifest
    {% raise "You no longer need to call Lucky::AssetHelpers.load_manifest. It is done autoamtically." %}
  end

  macro asset(path)
    {% if path.is_a?(StringLiteral) %}
      # If asset is not found
      {% unless Lucky::AssetHelpers::FINGERPINTED_ASSET_MAP[path] %}
        # Let's try to get it
        {% fingerprinted_path = run("../run_macros/get_fingerprinted_asset", path).stringify.chomp %}

        # If found, set it for use in later steps
        {% if fingerprinted_path && !fingerprinted_path.empty? %}
          {% FINGERPINTED_ASSET_MAP[path] = fingerprinted_path %}
        {% end %}
      {% end %}

      # If found in the asset map, return the fingerprinted asset path
      {% if fingerprinted_path = Lucky::AssetHelpers::FINGERPINTED_ASSET_MAP[path] %}
        (Lucky::Server.settings.asset_host + {{ fingerprinted_path }})
      # Otherwise, let the user know the asset does not exist.
      {% else %}
        {% asset_paths = Lucky::AssetHelpers::FINGERPINTED_ASSET_MAP.keys.join(",") %}
        {% run "../run_macros/missing_asset", path %}
      {% end %}
    {% elsif path.is_a?(StringInterpolation) %}
      {% raise <<-ERROR
      \n
      The 'asset' macro doesn't work with string interpolation

      Try this...

        ▸ Use the 'dynamic_asset' method instead

      ERROR
      %}
    {% else %}
      {% raise <<-ERROR
      \n
      The 'asset' macro requires a literal string like "my-logo.png", instead got: #{path}

      Try this...

        ▸ If you're using a variable, switch to a literal string
        ▸ If you can't use a literal string, use the 'dynamic_asset' method instead

      ERROR
      %}
    {% end %}
  end

  def dynamic_asset(path)
    fingerprinted_path =
      # If already in the fingerpinted asset map from compile time 'asset' call
      Lucky::AssetHelpers::FINGERPINTED_ASSET_MAP[path]? ||
        # If not, try getting it at runtime
        Lucky::AssetManifest.fingerpinted_path_for(path)

    if fingerprinted_path
      Lucky::Server.settings.asset_host + fingerprinted_path
    else
      raise "Missing asset: #{path}"
    end
  end
end
