module Lucky
  class WebSocket < HTTP::WebSocketHandler
    getter proc

    def initialize(@action : Lucky::Action.class, &@proc : HTTP::WebSocket, HTTP::Server::Context -> Void)
    end

  end
end
