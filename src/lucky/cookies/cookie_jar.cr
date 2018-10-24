class Lucky::CookieJar
  MAX_COOKIE_SIZE = 4096
  alias Key = String | Symbol
  private property cookies

  Habitat.create do
    setting default_expiration : Time::Span | Time::MonthSpan = 1.year
  end

  def self.from_request_cookies(cookies : HTTP::Cookies)
    new(cookies)
  end

  def self.empty_jar
    new
  end

  private def initialize
    @cookies = HTTP::Cookies.new
  end

  private def initialize(@cookies : HTTP::Cookies)
  end

  def raw : HTTP::Cookies
    cookies
  end

  def clear : Void
    cookies.each do |cookie|
      delete cookie.name
    end
  end

  def delete(key : Key) : Void
    raw[key.to_s].try &.expires(1.year.ago).value("")
  end

  def get_raw(key : Key) : HTTP::Cookie
    get_raw?(key) || raise "No cookie for '#{key}'"
  end

  def get_raw?(key : Key) : HTTP::Cookie?
    cookies[key.to_s]?
  end

  def get(key : Key) : String
    get?(key) || raise "No cookie for '#{key}'"
  end

  def get?(key : Key) : String?
    cookies[key.to_s]?.try do |cookie|
      decrypt(cookie.value)
    end
  end

  def set(key : Key, value : String) : HTTP::Cookie
    cookies[key.to_s] = HTTP::Cookie.new(
      name: key.to_s,
      value: encrypt(value),
      expires: settings.default_expiration.from_now,
      http_only: true,
    )
  end

  private def encrypt(raw_value : String) : String
    encrypted = encryptor.encrypt(raw_value)
    Base64.strict_encode(encrypted)
  end

  private def decrypt(base_64_encoded_value : String) : String
    decoded = Base64.decode(base_64_encoded_value)
    String.new(encryptor.decrypt(decoded))
  end

  @_encryptor : Lucky::MessageEncryptor?

  private def encryptor : Lucky::MessageEncryptor
    @_encryptor ||= Lucky::MessageEncryptor.new(secret_key)
  end

  private def secret_key
    Lucky::Server.settings.secret_key_base
  end
end
