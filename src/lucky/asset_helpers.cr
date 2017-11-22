module Lucky::AssetHelpers
  ASSET_MANIFEST = {} of String => String

  {{ run "../run_macros/generate_asset_helpers" }}

  macro asset(path)
    {% if ASSET_MANIFEST[path] %}
      {{ "/" + ASSET_MANIFEST[path] }}
    {% else %}
      {{ run "../run_macros/missing_asset", path }}
    {% end %}
  end
end
