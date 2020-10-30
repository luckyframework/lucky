module Lucky::LinkHelpers
  def link(text, to : Lucky::RouteHelper, attrs : Array(Symbol) = [] of Symbol, **html_options) : Nil
    a text, merge_options(html_options, link_to_href(to)), attrs
  end

  def link(text, to : Lucky::Action.class, attrs : Array(Symbol) = [] of Symbol, **html_options) : Nil
    a text, merge_options(html_options, link_to_href(to.route)), attrs
  end

  def link(to : Lucky::RouteHelper, attrs : Array(Symbol) = [] of Symbol, **html_options) : Nil
    a attrs, merge_options(html_options, link_to_href(to)) do
      yield
    end
  end

  def link(to : Lucky::Action.class, attrs : Array(Symbol) = [] of Symbol, **html_options) : Nil
    a attrs, merge_options(html_options, link_to_href(to.route)) do
      yield
    end
  end

  def link(to : Lucky::RouteHelper, attrs : Array(Symbol) = [] of Symbol, **html_options) : Nil
    a(attrs, merge_options(html_options, link_to_href(to))) { }
  end

  def link(to : Lucky::Action.class, attrs : Array(Symbol) = [] of Symbol, **html_options) : Nil
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
    {%
      raise <<-ERROR
      'link' no longer supports passing a String to 'to'.

      Use 'a()' or pass an Action class instead.

      Example:

        a "Home", href: "/"
        link "Home", to: Home::Index

      ERROR
    %}
  end

  def link(to : String, attrs : Array(Symbol) = [] of Symbol, **html_options)
    {%
      raise <<-ERROR
      'link' no longer supports passing a String to 'to'.

      Use 'a()' or pass an Action class instead.

      Example:

        a href: "/" do
        end

        link to: Home::Index do
        end

      ERROR
    %}
    yield
  end
end
