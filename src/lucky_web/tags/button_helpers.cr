require "./link_helpers"

module LuckyWeb::ButtonHelpers
  include LuckyWeb::LinkHelpers

  def button(text, to : LuckyWeb::RouteHelper, **html_options)
    a text, merge_options(html_options, link_to_href(to))
  end

  def button(text, to : LuckyWeb::Action.class, **html_options)
    a text, merge_options(html_options, link_to_href(to.with))
  end

  def button(to : LuckyWeb::RouteHelper, **html_options)
    a merge_options(html_options, link_to_href(to)) do
      yield
    end
  end

  def button(to : LuckyWeb::Action.class, **html_options)
    a merge_options(html_options, link_to_href(to.with)) do
      yield
    end
  end

  def button(text, to : String, **html_options)
    a text, merge_options(html_options, {"href" => to})
  end

  def button(to : String, **html_options)
    a merge_options(html_options, {"href" => to}) do
      yield
    end
  end
end
