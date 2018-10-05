class HTTP::Server::Context
  DEBUG_COLOR = :green
  setter cookies : Lucky::CookieJar?
  setter session : Lucky::SessionCookie?
  setter flash : Lucky::FlashStore?

  getter debug_messages : Array(String) = [] of String
  property? hide_from_logs : Bool = false

  def cookies
    @cookies ||= Lucky::Cookies::Processors::Encryptor.read(
      from: request
    )
  end

  def session
    @session ||= begin
      Lucky::SessionCookie.new(cookies.session_cookie)
    end
  end

  def flash
    @flash ||= Lucky::FlashStore.from_session(session)
  end

  def add_debug_message(message : String)
    {% if !flag?(:release) %}
      debug_messages << message
    {% end %}
  end
end
