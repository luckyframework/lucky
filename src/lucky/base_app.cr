# The Base class for creating an app server in Lucky
abstract class Lucky::BaseApp
  private getter server

  abstract def middleware : Array(HTTP::Handler)

  def initialize
    @server = HTTP::Server.new(middleware)
  end

  # :nodoc;
  def base_uri : String
    "http://#{host}:#{port}"
  end

  # :nodoc;
  def host : String
    Lucky::Server.settings.host
  end

  # :nodoc;
  def port : Int32
    Lucky::Server.settings.port
  end

  # :nodoc;
  def listen : Nil
    server.bind_tcp host, port
    server.listen
  end

  # :nodoc;
  def close : Nil
    server.close
  end
end
