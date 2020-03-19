module Lucky::ParamHelpers
  @_params : Lucky::Params?

  def params : Lucky::Params
    @_params ||= Lucky::Params.new(context.request, @route_params)
  end

  # A shortcut for request.query_params
  #
  # Returns an `HTTP::Params` object for just query params.
  # This is rarely helpful since you can get query params with
  # `Lucky::Params#get`, but if you do need raw access to the query params
  # this is a good way to get them.
  def query_params : HTTP::Params
    request.query_params
  end
end
