require "./text_helpers_spec"

class TextHelperTestPage
  def test_truncate
    truncate "Hello World", length: 8 do
      a "Continue", href: "#"
    end
  end

  def text_truncate_with_block_invoked
    truncate("Here is a long test and I need a continue to read link", length: 27) do
      a "Continue", href: "#"
    end
  end

  def text_truncate_without_block_invoked
    truncate("Hello World", length: 12) do
      a "Continue", href: "#"
    end
  end
end

describe Lucky::TextHelpers do
  describe "truncate" do
    it "truncates" do
      view.tap(&.truncate("Hello World!", length: 12)).render
        .should eq "Hello World!"
      view.tap(&.truncate("Hello World!!", length: 12)).render
        .should eq "Hello Wor..."
    end

    it "escapes the text by default" do
      view.tap(&.truncate("<span>escape me</span>", length: 12)).render
        .should eq "&lt;span&gt;esc..."
    end

    it "allows leaving the text unescaped" do
      view.tap(&.truncate("<span>leave me as-is</span>", length: 12, escape: false)).render
        .should eq "<span>lea..."
    end

    it "truncates with default length of 30" do
      str = "This is a string that will go longer then the default truncate length of 30"
      view.tap(&.truncate(str)).render.should eq str[0...27] + "..."
    end

    it "truncates with options" do
      view.tap(&.truncate("This is a string that will go longer then the default truncate length of 30", omission: "[...]")).render
        .should eq "This is a string that wil[...]"
      view.tap(&.truncate("Hello World!", length: 10)).render
        .should eq "Hello W..."
      view.tap(&.truncate("Hello World!", omission: "[...]", length: 10)).render
        .should eq "Hello[...]"
      view.tap(&.truncate("Hello Big World!", omission: "[...]", length: 13, separator: " ")).render
        .should eq "Hello[...]"
      view.tap(&.truncate("Hello Big World!", omission: "[...]", length: 14, separator: " ")).render
        .should eq "Hello Big[...]"
      view.tap(&.truncate("Hello Big World!", omission: "[...]", length: 15, separator: " ")).render
        .should eq "Hello Big[...]"
    end

    it "truncates with link options" do
      view.tap(&.text_truncate_with_block_invoked).render
        .should eq "Here is a long test and ...<a href=\"#\">Continue</a>"
      view.tap(&.text_truncate_without_block_invoked).render
        .should eq "Hello World"
    end
  end
end
