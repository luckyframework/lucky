class HTTP::Server::Context
  DEBUG_COLOR = :green
  getter debug_messages : Array(String) = [] of String
  property? hide_from_logs : Bool = false

  @_cookies : Lucky::CookieJar?

  def cookies
    @_cookies ||= Lucky::CookieJar.from_request_cookies(request.cookies)
  end

  @_session : Lucky::Session?

  def session
    @_session ||= Lucky::Session.from_cookie_jar(cookies)
  end

  @_flash : Lucky::FlashStore?

  def flash
    @_flash ||= Lucky::FlashStore.from_session(session)
  end

  def add_debug_message(message : String)
    {% if !flag?(:release) %}
      debug_messages << message
    {% end %}
  end
end
