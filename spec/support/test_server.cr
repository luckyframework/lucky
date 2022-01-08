class TestServer < Lucky::BaseAppServer
  class_property last_request : HTTP::Request?
  class_getter middleware = [LastRequestHandler.new] of HTTP::Handler

  def self.reset
    @@middleware = [LastRequestHandler.new] of HTTP::Handler
  end

  def middleware : Array(HTTP::Handler)
    @@middleware
  end

  def listen
    raise "unimplemented"
  end

  def last_request
    self.class.last_request.not_nil!
  end

  class LastRequestHandler
    include HTTP::Handler

    def call(context)
      TestServer.last_request = context.request
      call_next(context)
    end
  end
end
