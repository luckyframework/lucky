abstract class Lucky::WebSocketAction < Lucky::Action
  @socket : HTTP::WebSocket?
  @handler : HTTP::WebSocketHandler

  def initialize(@context : HTTP::Server::Context, @route_params : Hash(String, String))
    @handler = HTTP::WebSocketHandler.new do |ws|
      @socket = ws
      ws.on_ping { ws.pong("PONG") }
      call
    end
  end

  def perform_websocket_action
    @handler.call(@context)
  end

  def socket : HTTP::WebSocket
    @socket.not_nil!
  end
end
