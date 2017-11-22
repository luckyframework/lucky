module Lucky::ParamHelpers
  @_params : Lucky::Params?

  def params
    @_params ||= Lucky::Params.new(context.request, @route_params)
  end
end
