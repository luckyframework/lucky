class Lucky::CookieJar
  MAX_COOKIE_SIZE         = 4096
  LUCKY_ENCRYPTION_PREFIX = Base64.strict_encode("lucky") + "--"
  alias Key = String | Symbol
  private property cookies : HTTP::Cookies
  private property set_cookies : HTTP::Cookies

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

  # Delete all cookies.
  def clear : Nil
    clear { }
  end

  # Delete cookies with a block to add specific options.
  #
  # jar.clear do |cookie|
  #   cookie.path("/")
  #         .http_only(true)
  #         .secure(true)
  # end
  def clear(&block : HTTP::Cookie ->) : Nil
    cookies.each do |cookie|
      yield cookie
      delete cookie.name
    end
  end

  # https://tools.ietf.org/search/rfc6265#page-8
  # to remove a cookie, the server returns a Set-Cookie header
  # with an expiration date in the past. The server will be successful
  # in removing the cookie only if the Path and the Domain attribute in
  # the Set-Cookie header match the values used when the cookie was
  # created.
  def delete(key : Key) : Nil
    if cookie = cookies[key.to_s]?
      cookie.expires(1.year.ago).value("")
      set_cookies[key.to_s] = cookie
    end
  end

  # Delete a specific cookie by name `key`. Yield that cookie
  # to the block so you can add additional options like domain, path, etc...
  def delete(key : Key) : Nil
    if cookie = cookies[key.to_s]?
      yield cookie
      delete cookie.name
    end
  end

  # Returns `true` if the cookie has been expired, and has no value.
  # Will return `false` if the cookie does not exist, or is valid.
  def deleted?(key : Key) : Bool
    if cookie = cookies[key.to_s]?
      cookie.expired? && cookie.value == ""
    else
      false
    end
  end

  def get_raw(key : Key) : HTTP::Cookie
    get_raw?(key) || raise CookieNotFoundError.new(key)
  end

  def get_raw?(key : Key) : HTTP::Cookie?
    cookies[key.to_s]?
  end

  def get(key : Key) : String
    get?(key) || raise CookieNotFoundError.new(key)
  end

  def [](key : Key) : String
    get(key)
  end

  def get?(key : Key) : String?
    cookies[key.to_s]?.try do |cookie|
      decrypt(cookie.value, cookie.name)
    end
  rescue OpenSSL::Cipher::Error
    nil
  end

  def []?(key : Key) : String?
    get?(key)
  end

  def set(key : Key, value : String) : HTTP::Cookie
    set_raw key, encrypt(value)
  end

  def []=(key : Key, value : String) : HTTP::Cookie
    set(key, value)
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
  rescue IO::Error
    raise InvalidCookieValueError.new(key)
  end

  private def encrypt(raw_value : String) : String
    encrypted = encryptor.encrypt(raw_value)

    String.build do |value|
      value << LUCKY_ENCRYPTION_PREFIX
      value << Base64.strict_encode(encrypted)
    end
  end

  private def decrypt(cookie_value : String, cookie_name : String) : String?
    return unless encrypted_with_lucky?(cookie_value)

    base_64_encrypted_part = cookie_value.lchop(LUCKY_ENCRYPTION_PREFIX)
    decoded = Base64.decode(base_64_encrypted_part)
    String.new(encryptor.decrypt(decoded))
  rescue e
    # an error happened while decrypting the cookie
    # we will treat that as if no cookie was passed
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
