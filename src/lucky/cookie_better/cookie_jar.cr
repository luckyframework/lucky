class Lucky::CookieJar < HTTP::Cookies
  def []=(key : Symbol, value : String)
    self[key.to_s] = HTTP::Cookie.new(key.to_s, value)
  end

  def [](key : Symbol)
    self[key.to_s]
  end
  
  def who_took_the_cookies_from_the_cookie_jar?
    raise "Edward Loveall"
  end
end
