require "../spec_helper"

class LinkHelpers::Index < TestAction
  route { plain_text "foo" }
end

class LinkHelpers::Create < TestAction
  route { plain_text "foo" }
end

private class TestPage
  include Lucky::HTMLPage

  def render
  end

  def get_route
    link "Test", to: LinkHelpers::Index
  end

  def non_get_route
    link "Test", to: LinkHelpers::Create
  end

  def non_get_route_with_options
    link "Test", to: LinkHelpers::Create, something_custom: "foo"
  end

  def get_route_with_block
    link to: LinkHelpers::Index do
      text "Hello"
    end
  end

  def get_route_without_text
    link to: LinkHelpers::Index
  end

  def get_route_with_text_and_attrs
    link "Text", to: LinkHelpers::Index, attrs: [:disabled]
  end

  def get_route_with_attrs_no_text
    link to: LinkHelpers::Index, attrs: [:disabled]
  end

  def get_route_with_block_and_attrs
    link to: LinkHelpers::Index, attrs: [:disabled] do
      text "Hello"
    end
  end
end

describe Lucky::LinkHelpers do
  it "renders a link tag" do
    view.get_route.to_s.should contain %(<a href="/link_helpers">Test</a>)
    view.non_get_route.to_s.should contain %(<a href="/link_helpers" data-method="post">Test</a>)
    view
      .non_get_route_with_options
      .to_s
      .should contain %(<a href="/link_helpers" data-method="post" something-custom="foo">Test</a>)
  end

  it "renders a link tag with an action" do
    view.link("Test", to: LinkHelpers::Index).to_s.should contain <<-HTML
    <a href="/link_helpers">Test</a>
    HTML

    link = view.link(to: LinkHelpers::Index, class: "link") { }

    link.to_s.should contain <<-HTML
    <a href="/link_helpers" class="link"></a>
    HTML
  end

  it "renders a link tag with a block" do
    view.get_route_with_block.to_s.should contain <<-HTML
    <a href="/link_helpers">Hello</a>
    HTML
  end

  it "renders a link tag without text" do
    view.get_route_without_text.to_s.should contain <<-HTML
    <a href="/link_helpers"></a>
    HTML
  end

  it "renders a link with a special data attribute" do
    view.link(to: LinkHelpers::Index, "data-is-useless": true).to_s.should contain <<-HTML
    <a href="/link_helpers" data-is-useless="true"></a>
    HTML

    view.link(to: LinkHelpers::Index, "data-num": 4).to_s.should contain <<-HTML
    <a href="/link_helpers" data-num="4"></a>
    HTML
  end

  it "renders a link with boolean attrs" do
    view.get_route_with_text_and_attrs.to_s.should contain <<-HTML
    <a href="/link_helpers" disabled>Text</a>
    HTML

    view.get_route_with_attrs_no_text.to_s.should contain <<-HTML
    <a href="/link_helpers" disabled></a>
    HTML

    view.get_route_with_block_and_attrs.to_s.should contain <<-HTML
    <a href="/link_helpers" disabled>Hello</a>
    HTML
  end
end

private def view
  TestPage.new(build_context)
end
