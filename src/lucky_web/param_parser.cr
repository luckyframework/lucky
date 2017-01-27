module LuckyWeb::ParamParser
  def query_param(name)
    context.request.query_params[name.to_s]
  end

  def query_param?(name)
    context.request.query_params[name.to_s]?
  end
end
