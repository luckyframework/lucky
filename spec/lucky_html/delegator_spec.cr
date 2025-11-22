require "../spec_helper"
require "../../src/lucky_html"

include ContextHelper

# Test that LuckyHtml modules work as expected
describe "LuckyHtml delegator" do
  it "allows using LuckyHtml modules" do
    # Create a test page using LuckyHtml modules
    test_page = TestLuckyHtmlPage.new(context: build_context)
    
    # Test should compile and run
    test_page.perform_render.to_s.should contain("Hello from LuckyHtml")
  end

  it "allows using LuckyHtml components" do
    component = TestLuckyHtmlComponent.new
    component.render_to_string.should contain("LuckyHtml Component")
  end
end

# Test page using LuckyHtml modules
class TestLuckyHtmlPage
  include LuckyHtml::HTMLPage

  def render
    h1 "Hello from LuckyHtml"
  end
end

# Test component using LuckyHtml
class TestLuckyHtmlComponent < LuckyHtml::BaseComponent
  def render
    div "LuckyHtml Component"
  end
end