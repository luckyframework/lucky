require "../../spec_helper"

private class TestPage
  include Lucky::HTMLPage

  def render
  end

  def test_content_tag_with_block
    content_tag "p" do
      text "Foo bar baz"
    end
  end

  def test_content_tag_without_block
    content_tag "p", "Foo bar baz"
  end

  def test_content_tag_with_block_and_attrubute
    content_tag "a", href: "#foo" do
      text "Foo bar baz"
    end
  end

  def test_content_tag_without_block_and_extra_attrubute
    content_tag "a", "Foo bar baz", href: "#foo", bar: "baz"
  end

  def test_content_tag_with_block_and_attrubutes_as_hash
    content_tag "a", { href: "#foo", bar: "baz" } do
      text "Foo bar baz"
    end
  end

  def test_content_tag_with_symbol_and_attrubutes
    content_tag :a, "Foo bar baz", href: "#foo", bar: "baz"
  end

  def test_content_tag_with_symbol_block_and_attrubutes_as_hash
    content_tag :a, { href: "#foo", bar: "baz" } do
      text "Foo bar baz"
      br
      text "Foo bar baz"
    end
  end
end

describe Lucky::TagHelpers do
  Spec.before_each do
    view.reset_cycles
  end

  it "creates content by content tag" do
    view.test_content_tag_without_block.should eq "<p>Foo bar baz</p>"
  end

  it "creates content by content tag with block" do
    view.test_content_tag_with_block.should eq "<p>Foo bar baz</p>"
  end

  it "creates content by content tag with block and attribute" do
    view.test_content_tag_with_block_and_attrubute.should eq "<a href=\"#foo\">Foo bar baz</a>"
  end

  it "creates content by content tag without block and extra attribute" do
    view.test_content_tag_without_block_and_extra_attrubute.should eq "<a href=\"#foo\" bar=\"baz\">Foo bar baz</a>"
  end

  it "creates content by content tag with block and attributes as hash" do
    view.test_content_tag_with_block_and_attrubutes_as_hash.should eq "<a href=\"#foo\" bar=\"baz\">Foo bar baz</a>"
  end

  it "creates content by content tag with symbol and attributes" do
    view.test_content_tag_with_symbol_and_attrubutes.should eq "<a href=\"#foo\" bar=\"baz\">Foo bar baz</a>"
  end

  it "creates content by content tag with symbol, block and attributes as hash" do
    view.test_content_tag_with_symbol_block_and_attrubutes_as_hash.should eq "<a href=\"#foo\" bar=\"baz\">Foo bar baz<br/>Foo bar baz</a>"
  end
end

private def view
  TestPage.new
end
