module Lucky::ActionCookies
  @_cookies : Lucky::CookieJar?

  def better_cookies : Lucky::CookieJar
    @_cookies ||= Lucky::CookieJar.new
  end
end
