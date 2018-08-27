class Lucky::SessionStore < Lucky::AbstractStore
  Habitat.create do
    setting key : String
  end

  def self.from(cookies : Lucky::CookieJar) : Lucky::SessionStore
    new.from(cookies)
  end

  def from(cookies : Lucky::CookieJar)
    self.tap do |session_store|
      decoded = Base64.decode(cookies.get(settings.key))
      decrypted = encryptor.decrypt(decoded)
      JSON.parse(String.new(decrypted)).as_h.each do |key, value|
        session_store.set(key, value.to_s)
      end
    end
  end

  def transfer(to cookies : Lucky::CookieJar)
    encrypted_cookie = encryptor.encrypt(json)
    cookies.set(settings.key, Base64.strict_encode(encrypted_cookie))
  end

  private def json
    to_h.to_json
  end

  private def encryptor
    @_encryptor ||= Lucky::MessageEncryptor.
      new(Lucky::Server.settings.secret_key_base)
  end
end
