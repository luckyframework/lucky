module LuckyWeb::AssetHelpers
  ASSET_MANIFEST = {} of String => String

  {{ run "./generate_asset_helpers" }}
end
