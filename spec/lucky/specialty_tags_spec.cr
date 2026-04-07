require "../spec_helper"

include ContextHelper

private class TestPage
  include Lucky::HTMLPage

  def render
  end
end

describe Lucky::SpecialtyTags do
  it "renders doctype" do
    view(&.html_doctype).should contain <<-HTML
    <!DOCTYPE html>
    HTML
  end

  it "renders css link tag" do
    view(&.css_link("app.css")).should eq <<-HTML
    <link href="app.css" rel="stylesheet" media="screen">
    HTML

    view(&.css_link("app.css", rel: "preload", media: "print")).should eq <<-HTML
    <link href="app.css" rel="preload" media="print">
    HTML
  end

  it "cache-busts non-fingerprinted local css links" do
    html = view(&.css_link("/assets/css/app.css"))

    html.should contain "bust="
  end

  it "does not cache-bust fingerprinted local css links" do
    html = view(&.css_link("/assets/css/app-5e6f7a8b.css"))

    html.should_not contain "bust="
  end

  it "does not cache-bust external css links" do
    html = view(&.css_link("https://fonts.googleapis.com/css?family=Inter"))

    html.should_not contain "bust="
  end

  it "does not cache-bust protocol-relative css links" do
    html = view(&.css_link("//cdn.example.com/style.css"))

    html.should_not contain "bust="
  end

  it "does not cache-bust css links outside the asset path" do
    html = view(&.css_link("/other/path/style.css"))

    html.should_not contain "bust="
  end

  it "renders js link tag" do
    view(&.js_link("app.js")).should contain <<-HTML
    <script src="app.js"></script>
    HTML

    view(&.js_link("app.js", foo: "bar")).should contain <<-HTML
    <script src="app.js" foo="bar"></script>
    HTML
  end

  it "render utf8 meta tag" do
    view(&.utf8_charset).should contain <<-HTML
    <meta charset="utf-8">
    HTML
  end

  it "renders responsive meta tag" do
    view(&.responsive_meta_tag).should contain <<-HTML
    <meta name="viewport" content="width=device-width, initial-scale=1">
    HTML

    view(&.responsive_meta_tag(width: 600)).should contain <<-HTML
    <meta name="viewport" content="initial-scale=1, width=600">
    HTML

    view(&.responsive_meta_tag(height: 600)).should contain <<-HTML
    <meta name="viewport" content="width=device-width, initial-scale=1, height=600">
    HTML
  end

  it "renders canonical link tag" do
    view(&.canonical_link("https://it.is/here")).should contain <<-HTML
    <link href="https://it.is/here" rel="canonical">
    HTML
  end

  it "renders bun reload script in development" do
    html = view(&.bun_reload_connect_tag)

    html.should contain "<script>"
    html.should contain "new WebSocket"
    html.should contain "ws://127.0.0.1:3002"
  end

  it "uses bust param for css hmr" do
    html = view(&.bun_reload_connect_tag)

    html.should contain "searchParams.set('bust'"
  end

  it "does not render bun reload script in production" do
    ENV["LUCKY_ENV"] = "production"
    html = view(&.bun_reload_connect_tag)

    html.should_not contain "<script>"
  ensure
    ENV["LUCKY_ENV"] = "development"
  end

  it "renders proper non-breaking space entity" do
    view(&.nbsp).should contain <<-HTML
    &nbsp;
    HTML

    view(&.nbsp(3)).should contain <<-HTML
    &nbsp;&nbsp;&nbsp;
    HTML
  end
end

private def view(&)
  TestPage.new(build_context).tap do |page|
    yield page
  end.view.to_s
end
