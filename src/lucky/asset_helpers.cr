# Methods for returning the path to assets
#
# These methods will return fingerprinted paths, check assets at compile time,
# and allow for setting a CDN.
#
# For an in-depth guide check: https://luckyframework.org/guides/frontend/asset-handling
module Lucky::AssetHelpers
  ASSET_MANIFEST = {} of String => String
  CONFIG         = {has_loaded_manifest: false}

  macro load_manifest(manifest_file = "")
    {{ run "../run_macros/generate_asset_helpers", manifest_file }}
    {% CONFIG[:has_loaded_manifest] = true %}
  end

  # EXPERIMENTAL: This feature is experimental. Use this to test
  # vite integration with Lucky
  macro load_manifest(manifest_file, use_vite)
    {{ run "../run_macros/generate_asset_helpers", manifest_file, use_vite }}
    {% CONFIG[:has_loaded_manifest] = true %}
  end

  # Return the string path to an asset
  #
  # ```
  # # In a page or component:
  # # Will find the asset in `public/assets/images/logo.png`
  # img src: asset("images/logo.png")
  #
  # # Can also be used elsewhere by prepending Lucky::AssetHelpers
  # Lucky::AssetHelpers.asset("images/logo.png")
  # ```
  #
  # Note that assets are checked at compile time so if it is not found, Lucky
  # will let you know. It will also let you know if you had a typo and suggest an
  # asset that is close to what you typed.
  #
  # NOTE: This macro requires a `StringLiteral`. That means you cannot
  # interpolate strings like this: `asset("images/icon-#{service_name}.png")`.
  # instead use `dynamic_asset` if you need string interpolation.
  macro asset(path)
    {% unless CONFIG[:has_loaded_manifest] %}
      {% raise "No manifest loaded. Call 'Lucky::AssetHelpers.load_manifest'" %}
    {% end %}

    {% if path.is_a?(StringLiteral) %}
      {% if ::Lucky::AssetHelpers::ASSET_MANIFEST[path] %}
        Lucky::Server.settings.asset_host + {{ ::Lucky::AssetHelpers::ASSET_MANIFEST[path] }}
      {% else %}
        {% asset_paths = ::Lucky::AssetHelpers::ASSET_MANIFEST.keys.join(",") %}
        {{ run "../run_macros/missing_asset", path, asset_paths }}
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

  # Return the string path to an asset (allows string interpolation)
  #
  # ```
  # # In a page or component
  # # Will find the asset in `public/assets/images/logo.png`
  # img src: asset("images/logo.png")
  #
  # # Can also be used elsewhere by prepending Lucky::AssetHelpers
  # Lucky::AssetHelpers.asset("images/logo.png")
  # ```
  #
  # NOTE: This method does *not* check assets at compile time. The asset path
  # is found at runtime so it is possible the asset does not exist. Be sure to
  # manually test that the asset is returned as expected.
  def dynamic_asset(path) : String
    fingerprinted_path = Lucky::AssetHelpers::ASSET_MANIFEST[path]?
    if fingerprinted_path
      Lucky::Server.settings.asset_host + fingerprinted_path
    else
      raise "Missing asset: #{path}"
    end
  end
end
