require "./asset_builder/base"
require "./asset_builder/mix"
require "./asset_builder/vite"

# Class for configuring server settings
#
# The settings created here can be customized in each Lucky app by modifying them in your config/server.cr
class Lucky::Server
  Habitat.create do
    setting secret_key_base : String
    setting host : String
    setting port : Int32
    setting asset_host : String = ""
    setting asset_build_system : Lucky::AssetBuilder::Base = Lucky::AssetBuilder::Mix.new
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
    setting http2_enabled : Bool = false
    setting http2_cert_file : String? = nil
    setting http2_key_file : String? = nil
    setting http2_enable_h2c : Bool = false
    setting http2_h2c_upgrade_timeout : Int32 = 10
    setting http2_max_concurrent_streams : Int32 = 100
    setting http2_max_frame_size : Int32 = 16384
  end
end
