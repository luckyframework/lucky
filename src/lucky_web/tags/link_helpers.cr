module LuckyWeb::LinkHelpers
  def link(text, to : LuckyWeb::RouteHelper, **html_options)
    a text, merge_options(html_options, link_to_href(to))
  end

  private def link_to_href(route)
    if route.method == :get
      {"href" => route.path}
    else
      {"href" => route.path, "data_method" => route.method.to_s}
    end
  end

  def link(text, to : String, **html_options)
    a text, merge_options(html_options, {"href" => to})
  end

  private def merge_options(html_options, tag_attrs)
    options = {} of String => String
    if !html_options.empty?
      html_options.each do |key, value|
        options[key.to_s] = value
      end
    end

    tag_attrs.merge(options)
  end
end
