require "./link_helpers"

module Lucky::ButtonHelpers
  include Lucky::LinkHelpers

  def button(text, to : Lucky::RouteHelper, **html_options)
    button_tag text, merge_options(html_options, link_to_href(to))
  end

  def button(text, to : Lucky::Action.class, **html_options)
    button_tag text, merge_options(html_options, link_to_href(to.route))
  end

  def button(to : Lucky::RouteHelper, **html_options)
    button_tag merge_options(html_options, link_to_href(to)) do
      yield
    end
  end

  def button(to : Lucky::Action.class, **html_options)
    button_tag merge_options(html_options, link_to_href(to.route)) do
      yield
    end
  end

  def button(text, to : String, **html_options)
    button_tag text, merge_options(html_options, {"href" => to})
  end

  def button(to : String, **html_options)
    button_tag merge_options(html_options, {"href" => to}) do
      yield
    end
  end

  private def button_tag(content : String, options = {} of String => String)
    button_tag options do
      text content
    end
  end

  private def button_tag(options = {} of String => String, &block)
    @view << "<button" << build_tag_attrs(options) << ">"
    yield
    @view << "</button>"
  end
end
