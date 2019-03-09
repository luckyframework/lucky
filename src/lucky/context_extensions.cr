class HTTP::Server::Context
  property? hide_from_logs : Bool = false

  @_cookies : Lucky::CookieJar?

  def cookies : Lucky::CookieJar
    @_cookies ||= Lucky::CookieJar.from_request_cookies(request.cookies)
  end

  @_session : Lucky::Session?

  def session : Lucky::Session
    @_session ||= Lucky::Session.from_cookie_jar(cookies)
  end

  @_flash : Lucky::FlashStore?

  def flash : Lucky::FlashStore
    @_flash ||= Lucky::FlashStore.from_session(session)
  end
end
