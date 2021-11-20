require "../../spec_helper"

describe "Lucky::Paginator Components" do
  it "compiles and renders the components successfully" do
    pages = Lucky::Paginator.new(page: 5, item_count: 10, per_page: 1, full_path: "/")

    html = Lucky::Paginator::SimpleNav.new(pages).render_to_string
    html.should contain(%(role="navigation"))

    html = Lucky::Paginator::BootstrapNav.new(pages).render_to_string
    html.should contain(%(class="pagination"))

    html = Lucky::Paginator::BulmaNav.new(pages).render_to_string
    html.should contain(%(class="pagination"))
  end
end
