module Lucky::AssetHelpers
  ASSET_MANIFEST = {} of String => String

  {{ run "../run_macros/generate_asset_helpers" }}

  macro asset(path)
    {% if Lucky::AssetHelpers::ASSET_MANIFEST[path] %}
      {{ "/" + Lucky::AssetHelpers::ASSET_MANIFEST[path] }}
    {% else %}
      {{ run "../run_macros/missing_asset", path }}
    {% end %}
  end

  def dynamic_asset(path)
    fingerprinted_path = Lucky::AssetHelpers::ASSET_MANIFEST[path]?
    if fingerprinted_path
      "/" + fingerprinted_path
    else
      raise "Missing asset: #{path}"
    end
  end
end
