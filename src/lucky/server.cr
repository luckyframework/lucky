class Lucky::Server
  Habitat.create do
    setting secret_key_base : String
    setting host : String
    setting port : Int32
    setting asset_host : String = ""
    setting gzip_enabled : Bool = false
    setting gzip_content_types : Array(String) = %w(
      application/json
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
  end
end
