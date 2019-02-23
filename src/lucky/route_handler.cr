require "colorize"

class Lucky::RouteHandler
  include HTTP::Handler

  def call(context)
    handler = Lucky::Router.find_action(context.request)
    if handler
      Lucky.logger.debug("Handled by #{handler.payload.to_s.colorize.bold}")
      handler.payload.new(context, handler.params).perform_action
    else
      call_next(context)
    end
  end
end
