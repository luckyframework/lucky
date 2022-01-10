require "colorize"

class Lucky::RouteHandler
  include HTTP::Handler

  def call(context)
    handler = Lucky.router.find_action(context.request)
    if handler
      Lucky::Log.dexter.debug { {handled_by: handler.payload.to_s} }
      handler.payload.new(context, handler.params).perform_action
    else
      call_next(context)
    end
  end
end
