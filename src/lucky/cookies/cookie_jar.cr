class Lucky::CookieJar
  alias Key = String | Symbol
  private property store : HTTP::Cookies
  @changed = false
  MAX_COOKIE_SIZE = 4096

  Habitat.create do
    setting default_expiration : Time::Span | Time::MonthSpan
  end

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

  def get?(key : Key) : Lucky::MaybeCookie
    store[key.to_s]? || Lucky::NullCookie.new
  end

  def set(key : Key, value : String) : HTTP::Cookie
    @changed = true
    store[key.to_s] = HTTP::Cookie.new(
      key.to_s,
      value,
      expires: settings.default_expiration.from_now,
      http_only: true,
    )
  end

  def expire(key : Key)
    @changed = true
    store[key.to_s].expires(1.second.ago)
  end

  def changed?
    @changed
  end

  def each(&block : HTTP::Cookie ->)
    @store.each do |cookie|
      yield cookie
    end
  end

  def clear
    @store = HTTP::Cookies.new
  end

  def session_cookie
    if get?(Lucky::SessionCookie.settings.key).is_a?(Lucky::NullCookie)
      HTTP::Cookie.new(Lucky::SessionCookie.settings.key, "{}")
    else
      get(Lucky::SessionCookie.settings.key)
    end
  end

  def who_took_the_cookies_from_the_cookie_jar?
    raise "Edward Loveall"
  end
end
