class Lucky::CookieJar
  alias Key = String | Symbol
  private property store : HTTP::Cookies

  delegate to_h, to: @store

  def initialize(@store : HTTP::Cookies = HTTP::Cookies.new)
  end

  def []=(key, value)
    {% raise "[]= is gone, please use .set(key, value) instead" %}
  end

  def [](key)
    {% raise "[] is gone, please use .get(key) instead" %}
  end

  def get(key : Key) : HTTP::Cookie
    store[key.to_s]
  end

  def get?(key : Key) : HTTP::Cookie?
    store[key.to_s]?
  end

  def set(key : Key, value : String) : HTTP::Cookie
    store[key.to_s] = HTTP::Cookie.new(key.to_s, value)
  end

  def who_took_the_cookies_from_the_cookie_jar?
    raise "Edward Loveall"
  end
end
