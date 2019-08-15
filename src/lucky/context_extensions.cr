class HTTP::Server::Context
  # :nodoc:
  #
  # This is used to store the client's accepted/desired format
  # That way if there is an error, the Errors::Show action will
  # use the same format that the Action used without trying
  # to figure it out again.
  property _clients_desired_format : Symbol? = nil

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
