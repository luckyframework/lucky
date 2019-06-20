class Lucky::Server
  Habitat.create do
    setting secret_key_base : String
    setting host : String
    setting port : Int32
    setting asset_host : String = ""
  end
end
