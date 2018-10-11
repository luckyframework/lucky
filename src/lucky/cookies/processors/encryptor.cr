require "../../support/message_encryptor"

class Lucky::Cookies::Processors::Encryptor
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
    request.cookies.each do |cookie|
      decoded = Base64.decode(cookie.value)
      decrypted_value = String.new(encryptor.decrypt(decoded))
      cookie.value = decrypted_value
    end
    Lucky::CookieJar.new(request.cookies)
  end

  def write(cookie_jar : Lucky::CookieJar, to response : HTTP::Server::Response)
    cookie_jar.each do |cookie|
      encrypted = encryptor.encrypt(cookie.value)
      encoded = Base64.strict_encode(encrypted)
      cookie.value = encoded
      response.cookies[cookie.name] = cookie
    end
    response.cookies.add_response_headers(response.headers)
  end

  private def encryptor : Lucky::MessageEncryptor
    @encryptor ||= Lucky::MessageEncryptor
      .new(Lucky::Server.settings.secret_key_base)
  end
end
