abstract class Lucky::WebSocketAction < Lucky::Action
  getter websocket : Lucky::WebSocket

  def initialize(@context : HTTP::Server::Context, @route_params : Hash(String, String))
    @websocket = Lucky::WebSocket.new(self.class) do |ws|
      ws.on_message { |message| on_message(message) }
      ws.on_close { on_close }
      call(ws)
    end
  end

  abstract def call(socket : Lucky::WebSocket)

  def call
    raise <<-ERROR
    WebSocketAction must define `call(socket)`
    ERROR
  end
end
