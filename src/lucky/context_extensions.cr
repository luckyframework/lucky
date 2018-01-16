require "./session/**"

class HTTP::Server::Context
  DEBUG_COLOR = :green
  setter session : Lucky::Session::AbstractStore?
  setter cookies : Lucky::Cookies::Store?
  setter flash : Lucky::Flash::Store?

  getter debug_messages : Array(String) = [] of String
  property? hide_from_logs : Bool = false

  def cookies
    @cookies ||= Lucky::Cookies::Store.build(request, Lucky::Server.settings.secret_key_base)
  end

  def session
    @session ||= Lucky::Session::Store.new(cookies).build
  end

  def flash
    @flash ||= Lucky::Flash.from_session(session)
  end

  def add_debug_message(message : String)
    {% if !flag?(:release) %}
      debug_messages << message
    {% end %}
  end
end
