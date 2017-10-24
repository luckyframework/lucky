require "../../spec_helper"

class TestRender
  include LuckyWeb::Page

  render do
    render_complicated_html
  end

  private def render_complicated_html
    header({class: "header"}) do
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
  include LuckyWeb::Page

  render do
    text "<script>not safe</span>"
  end
end

class InnerPage
  include LuckyWeb::Page

  layout MainLayout

  render do
    text "Inner text"
  end

  def title
    "A great title"
  end
end

class MainLayout
  include LuckyWeb::Layout

  @page : InnerPage

  render do
    title @page.title

    body do
      @page.render_inner
    end
  end
end

describe LuckyWeb::Page do
  describe "tags that contain contents" do
    it "can be called with various arguments" do
      view.header("text").to_s.should eq %(<header>text</header> )
      view.header("text", {class: "stuff"}).to_s.should eq %(<header class="stuff">text</header> )
      view.header("text", class: "stuff").to_s.should eq %(<header class="stuff">text</header> )
    end

    it "dasherizes attribute names" do
      view.header("text", data_foo: "stuff").to_s.should eq %(<header data-foo="stuff">text</header> )
    end
  end

  describe "empty tags" do
    it "can be called with various arguments" do
      view.br.to_s.should eq %(<br/> )
      view.img(src: "my_src").to_s.should eq %(<img src="my_src"/> )
      view.img({src: "my_src"}).to_s.should eq %(<img src="my_src"/> )
      view.img({:src => "my_src"}).to_s.should eq %(<img src="my_src"/> )
    end
  end

  describe "HTML escaping" do
    it "escapes text" do
      UnsafePage.new.render.to_s.should eq "&lt;script&gt;not safe&lt;/span&gt;"
    end

    it "escapes HTML attributes" do
      unsafe = "<span>bad news</span>"
      escaped = "&lt;span&gt;bad news&lt;/span&gt;"
      view.img(src: unsafe).to_s.should eq %(<img src="#{escaped}"/> )
      view.img({src: unsafe}).to_s.should eq %(<img src="#{escaped}"/> )
      view.img({:src => unsafe}).to_s.should eq %(<img src="#{escaped}"/> )
    end
  end

  it "renders complicated HTML syntax" do
    view.render.to_s.should be_a(String)
  end

  it "can render raw strings" do
    view.raw("<safe>").to_s.should eq "<safe>"
  end

  describe "can be used to render layouts" do
    it "renders layouts" do
      InnerPage.new.render.to_s.should contain %(<title>A great title</title>)
      InnerPage.new.render.to_s.should contain %(<body>Inner text</body>)
    end
  end
end

private def view
  TestRender.new
end
