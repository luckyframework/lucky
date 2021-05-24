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
    view(&.para("foo")).should contain "<p>foo</p>"
  end

  it "renders allowed types in tags" do
    view(&.para(42)).should contain "<p>42</p>"
    view(&.para(MySpecialClass.new)).should contain "<p>it works</p>"
    view(&.para(1_i64)).should contain "<p>1</p>"
    view(&.para({"class" => "empty-content"})).should contain "<p class=\"empty-content\"></p>"
    view(&.hr).should contain "<hr>"

    # These throw compile-time error messages
    # view(&.h1(nil, class: "text"))
    # view(&.h1(Time.utc, class: "text"))
  end

  it "renders nested video with source tags and proper attributes" do
    view do |page|
      page.video(attrs: [:autoplay, :controls, :loop], poster: "https://luckyframework.org/nothing.png") do
        page.source(src: "https://luckyframework.org/nothing.mp4", type: "video/mp4")
      end
    end.should contain %{<video poster="https://luckyframework.org/nothing.png" autoplay controls loop><source src="https://luckyframework.org/nothing.mp4" type="video/mp4"></video>}

    view(&.video(id: "player", "data-stream": "https://luckyframework.org/demo.mp4")).should eq %{<video id="player" data-stream="https://luckyframework.org/demo.mp4"></video>}
  end

  it "renders a button with a disabled boolean attribute" do
    view(&.button("text", attrs: [:disabled])).should contain "<button disabled>text</button>"
  end

  it "renders an input with autofocus boolean attribute" do
    view(&.input(attrs: [:autofocus], type: "text")).to_s.should contain %{<input type="text" autofocus>}
  end

  describe "#style" do
    it "renders a style tag" do
      view(&.style("body { font-size: 2em; }")).should contain <<-HTML
      <style>body { font-size: 2em; }</style>
      HTML
    end
  end
end

private def view
  TestPage.new(build_context).tap do |page|
    yield page
  end.view.to_s
end
