require "./text_helpers_spec"

class TextHelperTestPage
  def test_simple_format_with_block
    simple_format("my cool test\n\nis great") do |formatted_text|
      para formatted_text, class: "this-is-a-custom-class"
    end
  end

  def test_simple_format_without_block
    simple_format("my cool test\n\nis great")
  end

  def test_simple_format_with_div
    simple_format("") do |txt|
      div txt
    end
  end

  def test_simple_format_with_custom_wrapper_and_multi_line_breaks
    simple_format("We want to put a wrapper...\n\n...right there.") do |txt|
      div txt
    end
  end
end

describe Lucky::TextHelpers do
  describe "simple_format" do
    it "simple_formats" do
      view.tap(&.simple_format("")).render.should eq "<p></p>"

      view.tap(&.simple_format("crazy\r\n cross\r platform linebreaks")).render
        .should eq "<p>crazy\n<br > cross\n<br > platform linebreaks</p>"
      view.tap(&.simple_format("A paragraph\n\nand another one!")).render
        .should eq "<p>A paragraph</p>\n\n<p>and another one!</p>"
      view.tap(&.simple_format("A paragraph\n With a newline")).render
        .should eq "<p>A paragraph\n<br > With a newline</p>"

      view.tap(&.simple_format("A\nB\nC\nD")).render
        .should eq "<p>A\n<br >B\n<br >C\n<br >D</p>"

      view.tap(&.simple_format("A\r\n  \nB\n\n\r\n\t\nC\nD")).render
        .should eq "<p>A\n<br >  \n<br >B</p>\n\n<p>\t\n<br >C\n<br >D</p>"

      view.tap(&.simple_format("This is a classy test", class: "test")).render
        .should eq "<p class=\"test\">This is a classy test</p>"
      view.tap(&.simple_format("para 1\n\npara 2", class: "test")).render
        .should eq %Q(<p class="test">para 1</p>\n\n<p class="test">para 2</p>)
    end

    it "simple_formats with custom wrapper" do
      view.tap(&.test_simple_format_with_div).render.should eq "<div></div>"
    end

    it "simple_formats with custom wrapper and multi line breaks" do
      view.tap(&.test_simple_format_with_custom_wrapper_and_multi_line_breaks)
        .render
        .should eq "<div>We want to put a wrapper...</div>\n\n<div>...right there.</div>"
    end

    it "escapes html by default" do
      text = "<b>Ok</b>"

      view.tap(&.simple_format(text)).render
        .should eq("<p>&lt;b&gt;Ok&lt;/b&gt;</p>")
    end

    it "allows raw HTML" do
      text = "<b>Ok</b>"

      view.tap(&.simple_format(text, escape: false)).render
        .should eq("<p><b>Ok</b></p>")
    end

    it "simple_formats without modifying the html options" do
      html_options = {class: "foobar"}
      passed_html_options = html_options.dup
      view.simple_format("some text", **passed_html_options)
      passed_html_options.should eq html_options
    end

    it "should" do
      view.tap(&.test_simple_format_without_block).render
        .should eq "<p>my cool test</p>\n\n<p>is great</p>"
      view.tap(&.test_simple_format_with_block).render
        .should eq "<p class=\"this-is-a-custom-class\">my cool test</p>\n\n<p class=\"this-is-a-custom-class\">is great</p>"
    end
  end
end
