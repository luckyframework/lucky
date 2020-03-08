module Lucky::LinkHelpers
  def link(text, to : Lucky::RouteHelper, attrs : Array(Symbol) = [] of Symbol, **html_options)
    a text, merge_options(html_options, link_to_href(to)), attrs
  end

  def link(text, to : Lucky::Action.class, attrs : Array(Symbol) = [] of Symbol, **html_options)
    a text, merge_options(html_options, link_to_href(to.route)), attrs
  end

  def link(to : Lucky::RouteHelper, attrs : Array(Symbol) = [] of Symbol, **html_options)
    a attrs, merge_options(html_options, link_to_href(to)) do
      yield
    end
  end

  def link(to : Lucky::Action.class, attrs : Array(Symbol) = [] of Symbol, **html_options)
    a attrs, merge_options(html_options, link_to_href(to.route)) do
      yield
    end
  end

  def link(to : Lucky::RouteHelper, attrs : Array(Symbol) = [] of Symbol, **html_options)
    a(attrs, merge_options(html_options, link_to_href(to))) { }
  end

  def link(to : Lucky::Action.class, attrs : Array(Symbol) = [] of Symbol, **html_options)
    a(attrs, merge_options(html_options, link_to_href(to.route))) { }
  end

  private def link_to_href(route)
    if route.method == :get
      {"href" => route.path}
    else
      {"href" => route.path, "data_method" => route.method.to_s}
    end
  end

  def link(text, to : String, attrs : Array(Symbol) = [] of Symbol, **html_options)
    a text, merge_options(html_options, {"href" => to}), attrs
  end

  def link(to : String, attrs : Array(Symbol) = [] of Symbol, **html_options)
    a attrs, merge_options(html_options, {"href" => to}) do
      yield
    end
  end

  def link(to : String, attrs : Array(Symbol) = [] of Symbol, **html_options)
    a(attrs, merge_options(html_options, {"href" => to})) { }
  end
end
