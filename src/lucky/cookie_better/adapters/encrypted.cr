class Lucky::BetterCookies::Adapters::Encrypted
  def self.read(from request : HTTP::Request)
    new.read(from: request)
  end

  def read(from request : HTTP::Request) : Lucky::CookieJar
    Lucky::CookieJar.new.tap do |cookies|
      request.cookies.each do |cookie|
        decoded = Base64.decode(cookie.value)
        decrypted_value = String.new(encryptor.decrypt(decoded))
        cookies.set(cookie.name, decrypted_value)
      end
    end
  end

  private def encryptor
    @encryptor ||= Lucky::MessageEncryptor.
      new(Lucky::Server.settings.secret_key_base)
  end
end
