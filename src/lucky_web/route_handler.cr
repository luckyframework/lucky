class LuckyWeb::RouteHandler
  include HTTP::Handler

  def call(context)
    handler = LuckyWeb::Router.find_action(context.request)
    if handler
      handler.payload.new(context, handler.params).perform_action
    else
      call_next(context)
    end
  end
end
