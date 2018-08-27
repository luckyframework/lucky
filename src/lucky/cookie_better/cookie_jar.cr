class Lucky::CookieJar < Lucky::AbstractStore
  def to_json
    to_h.to_json
  end

  def who_took_the_cookies_from_the_cookie_jar?
    raise "Edward Loveall"
  end
end
