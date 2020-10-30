# Pagination component using Bulma Pagination styles
#
# https://bulma.io/documentation/components/pagination/
class Lucky::Paginator::BulmaNav < Lucky::BaseComponent
  needs pages : Lucky::Paginator

  def render
    nav aria_label: "pagination", class: "pagination", role: "navigation" do
      ul class: "pagination-list" do
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
    li { a page.number, href: page.path, class: "pagination-link" }
  end

  def render_page_item(page : Lucky::Paginator::CurrentPage)
    li { a page.number, href: page.path, class: "pagination-link is-current" }
  end

  def render_page_item(gap : Lucky::Paginator::Gap)
    li do
      span class: "pagination-ellipsis" { raw "&hellip;" }
    end
  end

  def previous_link
    li { a "Previous", href: @pages.path_to_previous.to_s, class: "pagination-previous" }
  end

  def next_link
    li { a "Next", href: @pages.path_to_next.to_s, class: "pagination-next" }
  end
end
