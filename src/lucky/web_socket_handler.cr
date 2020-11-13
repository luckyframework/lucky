module Lucky
  class WebSocketHandler
    include HTTP::Handler

    def call(context : HTTP::Server::Context)
      if ws_route_found?(context) && websocket_upgrade_request?(context)
        websocket_action.payload.new(context, websocket_action.params).websocket.call(context)
      else
        call_next(context)
      end
    end

    private def ws_route_found?(context)
      !!websocket_action
    end

    memoize def websocket_action : LuckyRouter::Match(Lucky::Action.class)?
      Lucky::Router.find_action(:ws, context.request.path)
    end

    private def websocket_upgrade_request?(context)
      return unless upgrade = context.request.headers["Upgrade"]?
      return unless upgrade.compare("websocket", case_insensitive: true) == 0

      context.request.headers.includes_word?("Connection", "Upgrade")
    end
  end
end
