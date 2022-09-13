module Lucky::NoRequiredParamsAction
  def route : Lucky::RouteHelper
    Lucky::RouteHelper.new(method, path_from_parts).url
  end
end
