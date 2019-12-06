class Lucky::Server
  Habitat.create do
    setting secret_key_base : String
    setting host : String
    setting port : Int32
    setting asset_host : String = ""
    setting gzip_enabled : Bool = false
    setting gzip_content_types : Array(String) = %w(text/html text/javascript text/css image/svg+xml application/json
      text/plain application/xml text/csv font/otf font/ttf font/woff font/woff2)
  end
end
