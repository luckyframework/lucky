class Lucky::RouteNotFoundHandler
  include HTTP::Handler

  def call(context)
    raise Lucky::RouteNotFoundError.new(context)
  end
end
