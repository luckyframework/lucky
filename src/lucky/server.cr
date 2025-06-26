# Class for configuring server settings
#
# The settings created here can be customized in each Lucky app by modifying them in your config/server.cr
class Lucky::Server
  Habitat.create do
    setting secret_key_base : String
    setting host : String
    setting port : Int32
    setting asset_host : String = ""
    setting gzip_enabled : Bool = false
    setting gzip_content_types : Array(String) = %w(
      application/json
      application/javascript
      application/xml
      font/otf
      font/ttf
      font/woff
      font/woff2
      image/svg+xml
      text/css
      text/csv
      text/html
      text/javascript
      text/plain
    )
    # Number of times to retry loading the asset manifest file
    # Can also be set with LUCKY_ASSET_MANIFEST_RETRY_COUNT env var at compile time
    setting asset_manifest_retry_count : Int32 = 20
    # Delay in seconds between manifest loading retries
    # Can also be set with LUCKY_ASSET_MANIFEST_RETRY_DELAY env var at compile time
    setting asset_manifest_retry_delay : Float64 = 0.25
  end
end
