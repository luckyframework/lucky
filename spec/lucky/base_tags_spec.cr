require "../spec_helper"
include ContextHelper

private class TestPage
  include Lucky::HTMLPage

  def render
  end
end

class MySpecialClass
  include Lucky::AllowedInTags

  def to_s
    "it works"
  end
end

describe Lucky::BaseTags do
  it "renders para tag as <p>" do
    view.para("foo").to_s.should contain "<p>foo</p>"
  end

  it "renders allowed types in tags" do
    view.para(42).to_s.should contain "<p>42</p>"
    view.para(MySpecialClass.new).to_s.should contain "<p>it works</p>"
    view.para(1_i64).to_s.should contain "<p>1</p>"
    view.hr.to_s.should contain "<hr>"
  end

  it "renders nested video with source tags and proper attributes" do
    view do
      video(autoplay: "autoplay", loop: "loop", poster: "https://luckyframework.org/nothing.png") do
        source(src: "https://luckyframework.org/nothing.mp4", type: "video/mp4")
      end
    end.to_s.should contain %{<video autoplay="autoplay" loop="loop" poster="https://luckyframework.org/nothing.png"><source src="https://luckyframework.org/nothing.mp4" type="video/mp4"></video>}
  end

  it "renders a button with a disabled boolean attribute" do
    view.button("text", attrs: [:disabled]).to_s.should contain "<button disabled>text</button>"
  end

  it "renders an input with autofocus boolean attribute" do
    view.input(attrs: [:autofocus], type: "text").to_s.should contain %{<input type="text" autofocus>}
  end

  describe "#style" do
    it "renders a style tag" do
      view.style("body { font-size: 2em; }").to_s.should contain <<-HTML
      <style>body { font-size: 2em; }</style>
      HTML
    end
  end
end

private def view
  TestPage.new(build_context)
end

private def view
  with TestPage.new(build_context) yield
end
