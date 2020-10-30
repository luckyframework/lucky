module Lucky::FormHelpers
  Habitat.create do
    setting include_csrf_tag : Bool = true
  end

  def form_for(route : Lucky::RouteHelper, **html_options) : Nil
    form build_form_options(route, html_options) do
      csrf_hidden_input if settings.include_csrf_tag
      method_override_input(route)
      yield
    end
  end

  def form_for(route action : Lucky::Action.class, **html_options, &block) : Nil
    form_for action.route, **html_options, &block
  end

  private def form_method(route) : String
    if route.method == :get
      "get"
    else
      "post"
    end
  end

  private def build_form_options(route, html_options) : Hash
    options = merge_options(html_options, {
      "action" => route.path,
      "method" => form_method(route),
    })
    options["enctype"] = "multipart/form-data" if options.delete("multipart")

    options
  end

  private def method_override_input(route) : Nil
    unless [:post, :get].includes? route.method
      input type: "hidden", name: "_method", value: route.method.to_s
    end
  end
end
