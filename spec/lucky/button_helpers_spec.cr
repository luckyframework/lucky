require "../../spec_helper"

class ButtonHelpers::Index < Lucky::Action
  action { text "foo" }
end

class ButtonHelpers::Create < Lucky::Action
  action { text "foo" }
end

private class TestPage
  include Lucky::HTMLPage

  def render
  end

  def get_route
    button "Test", to: ButtonHelpers::Index
  end

  def non_get_route
    button "Test", to: ButtonHelpers::Create
  end

  def non_get_route_with_options
    button "Test", to: ButtonHelpers::Create, something_custom: "foo"
  end

  def string_path
    button "Test", to: "/foos"
  end

  def string_path_with_options
    button "Test", to: "/foos", data_method: "post"
  end

  def get_route_with_block
    button to: ButtonHelpers::Index do
      text "Hello"
    end
  end

  def string_path_with_block
    button to: "/foo" do
      text "Hello"
    end
  end
end

describe Lucky::ButtonHelpers do
  it "renders a button tag" do
    view.get_route.to_s.should contain %(<button href="/button_helpers">Test</button>)
    view.non_get_route.to_s.should contain %(<button href="/button_helpers" data-method="post">Test</button>)
    view
      .non_get_route_with_options
      .to_s
      .should contain %(<button href="/button_helpers" data-method="post" something-custom="foo">Test</button>)
    view.string_path.to_s.should contain %(<button href="/foos">Test</button>)
    view.string_path_with_options.to_s.should contain %(<button href="/foos" data-method="post">Test</button>)
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

  it "renders a button tag with a block" do
    view.string_path_with_block.to_s.should contain <<-HTML
    <button href="/foo">Hello</button>
    HTML

    view.get_route_with_block.to_s.should contain <<-HTML
    <button href="/button_helpers">Hello</button>
    HTML
  end
end

private def view
  TestPage.new(build_context)
end
