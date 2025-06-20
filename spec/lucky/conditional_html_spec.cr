require "../spec_helper"

include ContextHelper

# Test that HTML functionality can be conditionally excluded
describe "Conditional HTML loading" do
  it "Lucky HTML modules are available by default" do
    # This test verifies that HTML modules exist
    Lucky::HTMLPage.should_not be_nil
    Lucky::HTMLBuilder.should_not be_nil
    Lucky::BaseComponent.should_not be_nil
  end

  it "allows creating pages with Lucky HTML modules" do
    page = TestPage.new(context: build_context)
    page.perform_render.to_s.should contain("Test Page")
  end

  it "allows rendering components" do
    component = TestComponent.new
    component.render_to_string.should contain("Test Component")
  end

  pending "API-only apps can exclude HTML with lucky_no_html flag" do
    # This test would verify that HTML is excluded when compiled with -D lucky_no_html
    # but we can't test compile-time flags at runtime
    # This is documented for manual testing
  end
end

class TestPage
  include Lucky::HTMLPage

  def render
    h1 "Test Page"
  end
end

class TestComponent < Lucky::BaseComponent
  def render
    div "Test Component"
  end
end