# Pagination component using Bootstrap styles
#
# https://getbootstrap.com/docs/4.0/components/pagination/
class Lucky::Paginator::BootstrapNav < Lucky::BaseComponent
  needs pages : Lucky::Paginator

  def render
    nav aria_label: "pagination", role: "navigation" do
      ul class: "pagination", aria_label: "pagination" do
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
    li class: "page-item" do
      a page.number, href: page.path, class: "page-link"
    end
  end

  def render_page_item(page : Lucky::Paginator::CurrentPage)
    li class: "page-item active disabled" do
      a page.number, href: page.path, class: "page-link"
    end
  end

  def render_page_item(gap : Lucky::Paginator::Gap)
    li class: "page-item" do
      a class: "page-link disabled" { raw "&hellip;" }
    end
  end

  def previous_link
    li class: "page-item #{"disabled" if @pages.first_page?}" do
      a "Previous", href: @pages.path_to_previous.to_s, class: "page-link"
    end
  end

  def next_link
    li class: "page-item #{"disabled" if @pages.last_page?}" do
      a "Next", href: @pages.path_to_next.to_s, class: "page-link"
    end
  end
end
