require "colorize"

class Lucky::RouteHandler
  include HTTP::Handler

  def call(context)
    handler = Lucky::Router.find_action(context.request)
    if handler
      context.add_debug_message("Handled by #{handler.payload.to_s.colorize(HTTP::Server::Context::DEBUG_COLOR)}")
      handler.payload.new(context, handler.params).perform_action
    else
      call_next(context)
    end
  end
end
