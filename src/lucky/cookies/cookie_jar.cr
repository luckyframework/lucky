class Lucky::CookieJar
  MAX_COOKIE_SIZE         = 4096
  LUCKY_ENCRYPTION_PREFIX = Base64.encode("lucky") + "--"
  alias Key = String | Symbol
  private property cookies
  private property set_cookies

  Habitat.create do
    setting on_set : (HTTP::Cookie -> HTTP::Cookie)?
  end

  def self.from_request_cookies(cookies : HTTP::Cookies) : Lucky::CookieJar
    new(cookies)
  end

  def self.empty_jar : Lucky::CookieJar
    new
  end

  private def initialize
    @cookies = HTTP::Cookies.new
    @set_cookies = HTTP::Cookies.new
  end

  private def initialize(@cookies : HTTP::Cookies)
    @set_cookies = HTTP::Cookies.new
  end

  def raw : HTTP::Cookies
    cookies
  end

  def updated : HTTP::Cookies
    set_cookies
  end

  def destroy
    {% raise "CookieJar#destroy has been renamed to CookieJar#clear to match Hash#clear" %}
  end

  def unset(*args)
    {% raise "use CookieJar#delete instead of CookieJar#unset" %}
  end

  def clear : Void
    cookies.each do |cookie|
      delete cookie.name
    end
  end

  def delete(key : Key) : Nil
    if cookie = cookies[key.to_s]
      cookie.expires(1.year.ago).value("")
      set_cookies[key.to_s] = cookie
    end
  end

  def get_raw(key : Key) : HTTP::Cookie
    get_raw?(key) || raise "No cookie with the key: #{key}"
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
  rescue OpenSSL::Cipher::Error
    nil
  end

  def set(key : Key, value : String) : HTTP::Cookie
    set_raw key, encrypt(value)
  end

  def set_raw(key : Key, value : String) : HTTP::Cookie
    raw_cookie = HTTP::Cookie.new(
      name: key.to_s,
      value: value,
      http_only: true,
    ).tap do |cookie|
      settings.on_set.try(&.call(cookie))
    end
    if raw_cookie.to_set_cookie_header.bytesize > MAX_COOKIE_SIZE
      raise Lucky::CookieOverflowError.new("size of '#{key}' cookie is too big")
    end
    cookies[key.to_s] = set_cookies[key.to_s] = raw_cookie
  end

  private def encrypt(raw_value : String) : String
    encrypted = encryptor.encrypt(raw_value)

    String.build do |value|
      value << LUCKY_ENCRYPTION_PREFIX
      value << Base64.strict_encode(encrypted)
    end
  end

  private def decrypt(cookie_value : String, cookie_name : String) : String
    if encrypted_with_lucky?(cookie_value)
      base_64_encrypted_part = cookie_value.lchop(LUCKY_ENCRYPTION_PREFIX)
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

  private def encrypted_with_lucky?(value : String) : Bool
    value.starts_with?(LUCKY_ENCRYPTION_PREFIX)
  end

  @_encryptor : Lucky::MessageEncryptor?

  private def encryptor : Lucky::MessageEncryptor
    @_encryptor ||= Lucky::MessageEncryptor.new(secret_key)
  end

  private def secret_key : String
    Lucky::Server.settings.secret_key_base
  end
end
