require "./text_helpers_spec"

describe Lucky::TextHelpers do
  describe "simple_format" do
    it "simple_formats" do
      view.simple_format("").should eq "<p></p>"

      view.simple_format("crazy\r\n cross\r platform linebreaks").should eq "<p>crazy\n<br /> cross\n<br /> platform linebreaks</p>"
      view.simple_format("A paragraph\n\nand another one!").should eq "<p>A paragraph</p>\n\n<p>and another one!</p>"
      view.simple_format("A paragraph\n With a newline").should eq "<p>A paragraph\n<br /> With a newline</p>"

      text = "A\nB\nC\nD"
      view.simple_format(text).should eq "<p>A\n<br />B\n<br />C\n<br />D</p>"

      text = "A\r\n  \nB\n\n\r\n\t\nC\nD"
      view.simple_format(text).should eq "<p>A\n<br />  \n<br />B</p>\n\n<p>\t\n<br />C\n<br />D</p>"

      view.simple_format("This is a classy test", class: "test").should eq "<p class=\"test\">This is a classy test</p>"
      view.simple_format("para 1\n\npara 2", class: "test").should eq %Q(<p class="test">para 1</p>\n\n<p class="test">para 2</p>)
    end

    it "simple_formats with custom wrapper" do
      view.simple_format("", wrapper_tag: "div").should eq "<div></div>"
    end

    it "simple_formats with custom wrapper and multi line breaks" do
      view.simple_format("We want to put a wrapper...\n\n...right there.", wrapper_tag: "div").should eq "<div>We want to put a wrapper...</div>\n\n<div>...right there.</div>"
    end

    it "simple_formats without changing the text passed" do
      text = "<b>Ok</b><script>code!</script>"
      text_clone = text.dup
      view.simple_format(text)
      text.should eq text_clone
    end

    it "simple_format without modifying the html options" do
      options = { class: "foobar" }
      passed_options = options.dup
      view.simple_format("some text", **passed_options)
      passed_options.should eq options
    end

    it "simple_format_does_not_modify_the_options_hash" do
      options = { wrapper_tag: :div }
      passed_options = options.dup
      view.simple_format("some text", **passed_options)
      passed_options.should eq options
    end
  end
end
