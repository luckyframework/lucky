require "./*"

abstract class Lucky::WebSocketAction
  getter :context, :route_params
  getter websocket : Lucky::WebSocket

  def initialize(@context : HTTP::Server::Context, @route_params : Hash(String, String))
    @websocket = Lucky::WebSocket.new(self.class) do |ws|
      ws.on_ping { ws.pong(@context.request.path) }
      ws.on_message { |message| on_message(message) }
      ws.on_close { on_close }
      call(ws)
    end
  end

  abstract def call(socket : HTTP::WebSocket)

  include Lucky::ActionDelegates
  include Lucky::Exposable
  include Lucky::Routable
  include Lucky::Renderable
  include Lucky::ParamHelpers
  include Lucky::ActionPipes

end
