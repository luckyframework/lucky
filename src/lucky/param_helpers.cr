module Lucky::ParamHelpers
  @_params : Lucky::Params?

  def params : Lucky::Params
    @_params ||= Lucky::Params.new(context.request, @route_params)
  end
end
