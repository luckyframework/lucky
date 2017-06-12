module LuckyWeb::AssetHelpers
  ASSET_MANIFEST = {} of String => String

  {{ run "../run_macros/generate_asset_helpers" }}
end
