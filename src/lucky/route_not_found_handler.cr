class Lucky::RouteNotFoundHandler
  include HTTP::Handler

  def call(context)
    raise Lucky::RouteNotFoundError.new(context.request.method, context.request.path)
  end
end
