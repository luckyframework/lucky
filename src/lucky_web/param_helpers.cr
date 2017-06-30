module LuckyWeb::ParamHelpers
  @_params : LuckyWeb::Params?

  def params
    @_params ||= LuckyWeb::Params.new(context.request, @route_params)
  end
end
