require "../../spec_helper"

class LinkHelpers::Index < LuckyWeb::Action
  action { render_text "foo" }
end

class LinkHelpers::Create < LuckyWeb::Action
  action { render_text "foo" }
end

private class TestPage
  include LuckyWeb::Page

  render do
  end

  def get_route
    link "Test", to: LinkHelpers::Index.route
  end

  def non_get_route
    link "Test", to: LinkHelpers::Create.route
  end

  def non_get_route_with_options
    link "Test", to: LinkHelpers::Create.route, something_custom: "foo"
  end

  def string_path
    link "Test", to: "/foos"
  end

  def string_path_with_options
    link "Test", to: "/foos", data_method: "post"
  end

  def get_route_with_block
    link to: LinkHelpers::Index.route do
      text "Hello"
    end
  end

  def string_path_with_block
    link to: "/foo" do
      text "Hello"
    end
  end
end

describe LuckyWeb::LinkHelpers do
  it "renders a link tag" do
    view.get_route.to_s.should contain %(<a href="/link_helpers">\nTest\n</a> )
    view.non_get_route.to_s.should contain %(<a href="/link_helpers" data-method="post">\nTest\n</a> )
    view
      .non_get_route_with_options
      .to_s
      .should contain %(<a href="/link_helpers" data-method="post" something-custom="foo">\nTest\n</a> )
    view.string_path.to_s.should contain %(<a href="/foos">\nTest\n</a> )
    view.string_path_with_options.to_s.should contain %(<a href="/foos" data-method="post">\nTest\n</a> )
  end

  it "renders a link tag with an action" do
    view.link("Test", to: LinkHelpers::Index).to_s.should contain <<-HTML
    <a href="/link_helpers">\nTest\n</a>
    HTML

    link = view.link(to: LinkHelpers::Index, class: "link") { }

    link.to_s.should contain <<-HTML
    <a href="/link_helpers" class="link"></a>
    HTML
  end

  it "renders a link tag with a block" do
    view.string_path_with_block.to_s.should contain <<-HTML
    <a href="/foo">\nHello\n</a>
    HTML

    view.get_route_with_block.to_s.should contain <<-HTML
    <a href="/link_helpers">\nHello\n</a>
    HTML
  end
end

private def view
  TestPage.new
end
