class Lucky::Server
  Habitat.create do
    setting secret_key_base : String
  end
end
