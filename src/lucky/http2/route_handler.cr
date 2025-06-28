class Lucky::HTTP2::RouteHandler
  def call(context : HT2::Context) : Bool
    route = Lucky.router.find_http2_action(context.request)

    if route
      action_class = route.payload
      action_class.call(context, route.params)
      return true
    end

    false
  end
end
