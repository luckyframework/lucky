module Lucky::ActionCookies
  @_cookies : Lucky::CookieJar?

  def cookies : Lucky::CookieJar
    @_cookies ||= Lucky::CookieJar.new
  end
end
