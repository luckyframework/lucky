class LuckyWeb::RouteHandler
  include HTTP::Handler

  def call(context)
    handler = LuckyWeb::Router.find_action(context.request)
    if handler.found?
      body = handler.payload.new(context, handler.params).perform_action
    else
      context.response.print "Action not found for #{context.request.path}"
    end
  end
end
