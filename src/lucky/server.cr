# Class for configuring server settings
#
# The settings created here can be customized in each Lucky app by modifying them in your config/server.cr
class Lucky::Server
  Habitat.create do
    setting secret_key_base : String
    setting host : String
    setting port : Int32
    setting workers : Int32 = 1, validation: :validate_workers
    setting asset_host : String = ""
    setting gzip_enabled : Bool = false
    setting gzip_content_types : Array(String) = %w[
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
    ]
  end

  def self.validate_workers(value : Int32)
    value >= 1 || Habitat.raise_validation_error("workers must be at least 1")
  end
end
