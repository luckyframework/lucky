module LuckyWeb::FormHelpers
  def form_for(route : LuckyWeb::RouteHelper, **html_options)
    form action: route.path, method: form_method(route) do
      method_override_input(route)
      yield
    end
  end

  private def form_method(route)
    if route.method == :get
      "get"
    else
      "post"
    end
  end

  private def method_override_input(route)
    unless [:post, :get].includes? route.method
      input type: "hidden", name: "_method", value: route.method.to_s
    end
  end
end
