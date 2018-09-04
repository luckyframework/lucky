class Lucky::BetterCookies::Adapters::Encrypted
  def self.read(from request : HTTP::Request)
    new.read(from: request)
  end
  
  def self.write(
    cookie_jar : Lucky::CookieJar,
    to response : HTTP::Server::Response
  )
    new.write(cookie_jar: cookie_jar, to: response)
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

  def write(cookie_jar : Lucky::CookieJar, to response : HTTP::Server::Response)
    cookies = HTTP::Cookies.new
    cookie_jar.to_h.each do |key, value|
      encrypted = encryptor.encrypt(value)
      encoded = Base64.strict_encode(encrypted)
      cookies[key] = encoded
    end
    cookies.add_response_headers(response.headers)
  end

  private def encryptor
    @encryptor ||= Lucky::MessageEncryptor.
      new(Lucky::Server.settings.secret_key_base)
  end
end
