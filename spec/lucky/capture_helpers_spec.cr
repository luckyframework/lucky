require "../../spec_helper"

private class TestPage
  include Lucky::HTMLPage

  @content : String | Nil
  getter :content

  def render
  end

  def set_content
    @content = capture do
      link "Bar", "#foo"
    end
  end

  def content_used
    "captured: #{@content}"
  end
end

describe Lucky::CaptureHelpers do
  it "captures content" do
    view = TestPage.new
    content = view.set_content
    view.content.should eq "<a href=\"#foo\">Bar</a>"
    view.content_used.should eq "captured: <a href=\"#foo\">Bar</a>"
  end
end
