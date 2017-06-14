require "../../spec_helper"

class LinkHelpers::Index < LuckyWeb::Action
  action do
    render_text "Hello"
  end
end

class LinkHelpers::Create < LuckyWeb::Action
  action do
    render_text "Hello"
  end
end

private class TestPage < LuckyWeb::Page
  def render
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
end

describe LuckyWeb::LinkHelpers do
  it "renders a link tag" do
    view.get_route.to_s.should contain %(<a href="/link_helpers">Test</a>)
    view.non_get_route.to_s.should contain %(<a href="/link_helpers" data-method="post">Test</a>)
    view
      .non_get_route_with_options
      .to_s
      .should contain %(<a href="/link_helpers" data-method="post" something-custom="foo">Test</a>)
    view.string_path.to_s.should contain %(<a href="/foos">Test</a>)
    view.string_path_with_options.to_s.should contain %(<a href="/foos" data-method="post">Test</a>)
  end
end

private def view
  TestPage.new
end
