class Lucky::CookieJar
  MAX_COOKIE_SIZE                = 4096
  LUCKY_ENCRYPTION_PREFIX        = Base64.strict_encode("lucky") + "--"
  LEGACY_LUCKY_ENCRYPTION_PREFIX = Base64.encode("lucky") + "--"
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

  # Delete all cookies.
  def clear : Void
    clear { }
  end

  # Delete cookies with a block to add specific options.
  #
  # jar.clear do |cookie|
  #   cookie.path("/")
  #         .http_only(true)
  #         .secure(true)
  # end
  def clear(&block : HTTP::Cookie ->) : Void
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

  private def decrypt(cookie_value : String, cookie_name : String) : String
    req_id = "#{rand(10_000)}"
    if encrypted_with_lucky?(cookie_value)
      Lucky::Log.dexter.info { { req: req_id, cookie_value: cookie_value, cookie_name: cookie_name, message: "NEW COOKIE. BEFORE LCHOP"} }
      base_64_encrypted_part = cookie_value.lchop(LUCKY_ENCRYPTION_PREFIX)
      Lucky::Log.dexter.info { { req: req_id, base_64_encrypted_part: base_64_encrypted_part, message: "AFTER LCHOP", encryption_prefix: LUCKY_ENCRYPTION_PREFIX} }
      begin
        decoded = Base64.decode(base_64_encrypted_part)
        Lucky::Log.dexter.info { { req: req_id, decoded: String.new(decoded), message: "BASE64 DECODE SUCCEEDED. TRYING DECRYPT"} }
        decrypted = encryptor.decrypt(decoded)
        Lucky::Log.dexter.info { { req: req_id, decrypted: String.new(decrypted), message: "DECRYPT SUCCEEDED"} }
        String.new(decrypted)
      rescue e
        Lucky::Log.dexter.info { { req: req_id, error: e.message, message: "BASE64 DECODE FAILED"} }
        raise "WOMP WOMP"
      end
    elsif encrypted_with_legacy?(cookie_value)
      Lucky::Log.dexter.info { { req: req_id, cookie_value: cookie_value, cookie_name: cookie_name, message: "LEGACY COOKIE. BEFORE NEW COOKIE VALUE"} }
      new_cookie_value = update_from_legacy_value(cookie_value)
      Lucky::Log.dexter.info { { req: req_id, cookie_value: new_cookie_value, cookie_name: cookie_name, message: "LEGACY COOKIE. AFTER NEW COOKIE VALUE", encryption_prefix: LEGACY_LUCKY_ENCRYPTION_PREFIX} }
      decrypt(new_cookie_value, cookie_name)
    else
      raise <<-ERROR
      It looks like this cookie's value is not encrypted by Lucky. This likely means the cookie was set by something other than Lucky, like a client side script.

      You can access the raw value by using 'get_raw':

          cookies.get_raw(:#{cookie_name}).value

      ERROR
    end
  end

  private def update_from_legacy_value(value : String) : String
    decoded_value = URI.decode_www_form(value)
    LUCKY_ENCRYPTION_PREFIX + decoded_value.lchop(LEGACY_LUCKY_ENCRYPTION_PREFIX)
  end

  private def encrypted_with_lucky?(value : String) : Bool
    value.starts_with?(LUCKY_ENCRYPTION_PREFIX)
  end

  # legacy encrypted values had a \n between the encoded lucky and -- and were also www form encoded
  # this allows apps made before 0.27.0 to not have to log all users out
  private def encrypted_with_legacy?(value : String) : Bool
    decoded_value = URI.decode_www_form(value)
    decoded_value.starts_with?(LEGACY_LUCKY_ENCRYPTION_PREFIX)
  end

  @_encryptor : Lucky::MessageEncryptor?

  private def encryptor : Lucky::MessageEncryptor
    @_encryptor ||= Lucky::MessageEncryptor.new(secret_key)
  end

  private def secret_key : String
    Lucky::Server.settings.secret_key_base
  end
end
