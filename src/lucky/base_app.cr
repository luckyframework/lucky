# The Base class for creating an app server in Lucky
abstract class Lucky::BaseApp
  private getter server

  abstract def middleware : Array(HTTP::Handler)

  def initialize
    @server = HTTP::Server.new(middleware)
  end

  # :nodoc;
  def base_uri
    "http://#{host}:#{port}"
  end

  # :nodoc;
  def host
    Lucky::Server.settings.host
  end

  # :nodoc;
  def port
    Lucky::Server.settings.port
  end

  # :nodoc;
  def listen
    server.bind_tcp host, port
    server.listen
  end

  # :nodoc;
  def close
    server.close
  end
end
