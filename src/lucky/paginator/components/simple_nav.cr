# Pagination component with raw html and no styling
#
# Typically you would copy paste this component source into your app
# and modify it to suite your needs.
class Lucky::Paginator::SimpleNav < Lucky::BaseComponent
  needs pages : Lucky::Paginator

  def render
    nav aria_label: "pagination", role: "navigation" do
      ul do
        previous_link
        page_links
        next_link
      end
    end
  end

  def page_links
    @pages.series(begin: 1, left_of_current: 1, right_of_current: 1, end: 1).each do |item|
      render_page_item(item)
    end
  end

  def render_page_item(page : Lucky::Paginator::Page)
    li do
      a page.number, href: page.path
    end
  end

  def render_page_item(page : Lucky::Paginator::CurrentPage)
    li do
      text page.number
    end
  end

  def render_page_item(gap : Lucky::Paginator::Gap)
    li "..."
  end

  def previous_link
    if prev_path = @pages.path_to_previous
      li { a "Previous", href: prev_path }
    else
      li "Previous"
    end
  end

  def next_link
    if path_to_next = @pages.path_to_next
      li { a "Next", href: path_to_next }
    else
      li "Next"
    end
  end
end
