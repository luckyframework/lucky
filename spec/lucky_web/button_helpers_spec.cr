require "../../spec_helper"

class ButtonHelpers::Index < LuckyWeb::Action
  action { render_text "foo" }
end

class ButtonHelpers::Create < LuckyWeb::Action
  action { render_text "foo" }
end

private class TestPage
  include LuckyWeb::Page

  render do
  end

  def get_route
    button "Test", to: ButtonHelpers::Index.route
  end

  def non_get_route
    button "Test", to: ButtonHelpers::Create.route
  end

  def non_get_route_with_options
    button "Test", to: ButtonHelpers::Create.route, something_custom: "foo"
  end

  def string_path
    button "Test", to: "/foos"
  end

  def string_path_with_options
    button "Test", to: "/foos", data_method: "post"
  end

  def get_route_with_block
    button to: ButtonHelpers::Index.route do
      text "Hello"
    end
  end

  def string_path_with_block
    button to: "/foo" do
      text "Hello"
    end
  end
end

describe LuckyWeb::ButtonHelpers do
  it "renders a button tag" do
    view.get_route.to_s.should contain %(<a href="/button_helpers">Test</a>)
    view.non_get_route.to_s.should contain %(<a href="/button_helpers" data-method="post">Test</a>)
    view
      .non_get_route_with_options
      .to_s
      .should contain %(<a href="/button_helpers" data-method="post" something-custom="foo">Test</a>)
    view.string_path.to_s.should contain %(<a href="/foos">Test</a>)
    view.string_path_with_options.to_s.should contain %(<a href="/foos" data-method="post">Test</a>)
  end

  it "renders a link tag with an action" do
    view.link("Test", to: ButtonHelpers::Index).to_s.should contain <<-HTML
    <a href="/button_helpers">Test</a>
    HTML

    link = view.link(to: ButtonHelpers::Index, class: "link") { }

    link.to_s.should contain <<-HTML
    <a href="/button_helpers" class="link"></a>
    HTML
  end

  it "renders a link tag with a block" do
    view.string_path_with_block.to_s.should contain <<-HTML
    <a href="/foo">Hello</a>
    HTML

    view.get_route_with_block.to_s.should contain <<-HTML
    <a href="/button_helpers">Hello</a>
    HTML
  end
end

private def view
  TestPage.new
end
