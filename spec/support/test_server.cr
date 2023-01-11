class TestServer < Lucky::BaseAppServer
  class_setter last_request : HTTP::Request?

  def self.last_request : HTTP::Request
    @@last_request.as(HTTP::Request)
  end

  def middleware : Array(HTTP::Handler)
    [
      LastRequestHandler.new,
      Lucky::RouteHandler.new,
    ] of HTTP::Handler
  end

  def listen
    raise "unimplemented"
  end

  def last_request : HTTP::Request
    self.class.last_request.as(HTTP::Request)
  end

  class LastRequestHandler
    include HTTP::Handler

    def call(context)
      TestServer.last_request = context.request
      call_next(context)
    end
  end
end
