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

  it "renders proper non-breaking space entity" do
    view(&.nbsp).should contain <<-HTML
    &nbsp;
    HTML

    view(&.nbsp(3)).should contain <<-HTML
    &nbsp;&nbsp;&nbsp;
    HTML
  end
end

private def view
  TestPage.new(build_context).tap do |page|
    yield page
  end.view.to_s
end
