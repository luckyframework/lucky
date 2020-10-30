require "../spec_helper"

include ContextHelper

class TestRender
  include Lucky::HTMLPage

  def render : String
    render_complicated_html
    view.to_s
  end

  private def render_complicated_html
    header({class: "header"}) do
      style "body { font-size: 2em; }"
      text "my text"
      h1 "h1"
      br
      div class: "empty-contents"
      br({class: "br"})
      br class: "br"
      img({src: "src"})
      h2 "A bit smaller", {class: "peculiar"}
      h6 class: "h6" do
        small "super tiny", class: "so-small"
        span "wow"
      end
    end
  end
end

class UnsafePage
  include Lucky::HTMLPage

  def render
    text "<script>not safe</span>"
    view.to_s
  end
end

abstract class MainLayout
  include Lucky::HTMLPage

  def render
    title page_title

    body do
      inner
    end
    view.to_s
  end

  abstract def inner
  abstract def page_title
end

class InnerPage < MainLayout
  needs foo : String

  def inner
    text "Inner text"
    text @foo
  end

  def page_title
    "A great title"
  end
end

class LessNeedyDefaultsPage < MainLayout
  needs a_string : String = "string default"
  needs bool : Bool = false
  needs nil_default : String? = nil
  needs inferred_nil_default : String?
  needs inferred_nil_default2 : String | Nil

  def inner
    div @a_string
    div("bool default") if @bool == false
    div("nil default") if @nil_default.nil?
    div("inferred nil default") if @inferred_nil_default.nil?
    div("inferred nil default 2") if @inferred_nil_default2.nil?
  end

  def page_title
    "Boolean Default"
  end
end

describe Lucky::HTMLPage do
  describe "tags that contain contents" do
    it "can be called with various arguments" do
      view(&.header("text")).should eq %(<header>text</header>)
      view(&.header("text", {class: "stuff"})).should eq %(<header class="stuff">text</header>)
      view(&.header("text", class: "stuff")).should eq %(<header class="stuff">text</header>)
    end

    it "dasherizes attribute names" do
      view(&.header("text", data_foo: "stuff")).should eq %(<header data-foo="stuff">text</header>)
    end
  end

  describe "empty tags" do
    it "can be called with various arguments" do
      view(&.br).should eq %(<br>)
      view(&.img(src: "my_src")).should eq %(<img src="my_src">)
      view(&.img({src: "my_src"})).should eq %(<img src="my_src">)
      view(&.img({:src => "my_src"})).should eq %(<img src="my_src">)
    end
  end

  describe "HTML escaping" do
    it "escapes text" do
      UnsafePage.new(build_context).render.should eq "&lt;script&gt;not safe&lt;/span&gt;"
    end

    it "escapes HTML attributes" do
      unsafe = "<span>bad news</span>"
      escaped = "&lt;span&gt;bad news&lt;/span&gt;"
      view(&.img(src: unsafe)).should eq %(<img src="#{escaped}">)
      view(&.img({src: unsafe})).should eq %(<img src="#{escaped}">)
      view(&.img({:src => unsafe})).should eq %(<img src="#{escaped}">)
    end
  end

  it "renders complicated HTML syntax" do
    TestRender.new(build_context).render.should be_a(String)
  end

  it "can render raw strings" do
    view(&.raw("<safe>")).should eq "<safe>"
  end

  describe "can be used to render layouts" do
    it "renders layouts and needs" do
      InnerPage.new(build_context, foo: "bar").render.should contain %(<title>A great title</title>)
      InnerPage.new(build_context, foo: "bar").render.should contain %(<body>Inner textbar</body>)
    end
  end

  describe "needs with defaults" do
    it "allows default values to needs" do
      LessNeedyDefaultsPage.new(build_context).render.should contain %(<div>string default</div>)
    end

    it "allows false as default value to needs" do
      LessNeedyDefaultsPage.new(build_context).render.should contain %(<div>bool default</div>)
    end

    it "allows nil as default value to needs" do
      LessNeedyDefaultsPage.new(build_context).render.should contain %(<div>nil default</div>)
    end

    it "infers the default value from nilable needs" do
      LessNeedyDefaultsPage.new(build_context).render.should contain %(<div>inferred nil default</div>)
    end

    it "infers the default value from nilable needs" do
      LessNeedyDefaultsPage.new(build_context).render.should contain %(<div>inferred nil default 2</div>)
    end
  end

  it "accepts extra arguments so pages are more flexible with exposures" do
    InnerPage.new(build_context, foo: "bar", ignore_me: true)
  end
end

private def view
  TestRender.new(build_context).tap do |page|
    yield page
  end.view.to_s
end
