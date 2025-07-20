module Lucky
  class WebSocketRouteHandler
    include HTTP::Handler

    def call(context : HTTP::Server::Context)
      if websocket_upgrade_request?(context)
        handler = Lucky::Router.find_action(:ws, context.request.path)
        if handler
          Lucky::Log.dexter.debug { {handled_by: handler.payload.to_s} }
          handler.payload.new(context, handler.params).as(Lucky::WebSocketAction).perform_websocket_action
        else
          call_next(context)
        end
      else
        call_next(context)
      end
    end

    private def websocket_upgrade_request?(context)
      return unless upgrade = context.request.headers["Upgrade"]?
      return unless upgrade.compare("websocket", case_insensitive: true) == 0

      context.request.headers.includes_word?("Connection", "Upgrade")
    end
  end
end
