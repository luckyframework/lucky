class Lucky::Adapters::EncryptedAdapter
  ONE_YEAR = 1.year.from_now

  def write(
    key : String,
    cookies : Lucky::CookieJar,
    to response : HTTP::Server::Response
  )
    encrypted_cookie = encryptor.encrypt(cookies.to_json)
    cookie = HTTP::Cookie.new(name: key, value: Base64.strict_encode(encrypted_cookie), expires: ONE_YEAR)
    response.cookies[key] = cookie
    add_cookies_to_response(response)
  end

  def read(key : String, from request : HTTP::Request) : Lucky::CookieJar
    return Lucky::CookieJar.new if !request.cookies[key]?
    Lucky::CookieJar.new.tap do |cookie_jar|
      decoded = Base64.decode(request.cookies[key].value)
      decrypted = encryptor.decrypt(decoded)
      JSON.parse(String.new(decrypted)).as_h.each do |key, value|
        cookie_jar.set key, value.to_s
      end
    end
  end

  private def add_cookies_to_response(response : HTTP::Server::Response)
    response.cookies.add_response_headers(response.headers)
  end

  private def encryptor
    @_encryptor ||= Lucky::MessageEncryptor.
      new(Lucky::Server.settings.secret_key_base)
  end
end
