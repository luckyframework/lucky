require "../../spec_helper"

private class TestPage
  include Lucky::HTMLPage

  def render
  end
end

describe Lucky::SpecialtyTags do
  it "renders doctype" do
    view.html_doctype.to_s.should contain <<-HTML
    <!DOCTYPE html>
    HTML
  end

  it "renders css link tag" do
    view.css_link("app.css").to_s.should contain <<-HTML
    <link href="app.css" rel="stylesheet" media="screen">
    HTML

    view.css_link("app.css", rel: "preload", media: "print").to_s.should contain <<-HTML
    <link href="app.css" rel="preload" media="print">
    HTML
  end

  it "renders js link tag" do
    view.js_link("app.js").to_s.should contain <<-HTML
    <script src="app.js"></script>
    HTML

    view.js_link("app.js", foo: "bar").to_s.should contain <<-HTML
    <script src="app.js" foo="bar"></script>
    HTML
  end

  it "render utf8 meta tag" do
    view.utf8_charset.to_s.should contain <<-HTML
    <meta charset="utf-8">
    HTML
  end
end

private def view
  TestPage.new
end
