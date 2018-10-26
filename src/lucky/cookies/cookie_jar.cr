class Lucky::CookieJar
  MAX_COOKIE_SIZE   = 4096
  ENCRYPTION_PREFIX = Base64.encode("lucky") + "--"
  alias Key = String | Symbol
  private property cookies

  Habitat.create do
    setting on_set : (HTTP::Cookie -> HTTP::Cookie) | Nil
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
      decrypt(cookie.value, cookie.name)
    end
  end

  def set(key : Key, value : String) : HTTP::Cookie
    set_raw key, encrypt(value)
  end

  def set_raw(key : Key, value : String) : HTTP::Cookie
    cookies[key.to_s] = HTTP::Cookie.new(
      name: key.to_s,
      value: value,
      http_only: true,
    ).tap do |cookie|
      settings.on_set.try(&.call(cookie))
    end
  end

  private def encrypt(raw_value : String) : String
    encrypted = encryptor.encrypt(raw_value)

    String.build do |value|
      value << ENCRYPTION_PREFIX
      value << Base64.strict_encode(encrypted)
    end
  end

  private def decrypt(cookie_value : String, cookie_name : String) : String
    if encrypted?(cookie_value)
      base_64_encrypted_part = cookie_value.lchop(ENCRYPTION_PREFIX)
      decoded = Base64.decode(base_64_encrypted_part)
      String.new(encryptor.decrypt(decoded))
    else
      raise <<-ERROR
      It looks like this cookie's value is not encrypted by Lucky. This likely means the cookie was set by something other than Lucky, like a client side script.

      You can access the raw value by using 'get_raw':

          cookies.get_raw(:#{cookie_name}).value

      ERROR
    end
  end

  private def encrypted?(value : String) : Bool
    value.starts_with?(ENCRYPTION_PREFIX)
  end

  @_encryptor : Lucky::MessageEncryptor?

  private def encryptor : Lucky::MessageEncryptor
    @_encryptor ||= Lucky::MessageEncryptor.new(secret_key)
  end

  private def secret_key
    Lucky::Server.settings.secret_key_base
  end
end
