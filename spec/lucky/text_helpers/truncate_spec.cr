require "./text_helpers_spec"

class TextHelperTestPage
  def test_truncate
    truncate "Hello World", length: 8 do
      link "Continue", "#"
    end
  end
end

describe Lucky::TextHelpers do
  describe "truncate" do
    it "truncates" do
      view.truncate("Hello World!", length: 12).should eq "Hello World!"
      view.truncate("Hello World!!", length: 12).should eq "Hello Wor..."
    end

    it "truncates with default length of 30" do
      str = "This is a string that will go longer then the default truncate length of 30"
      view.truncate(str).should eq str[0...27] + "..."
    end

    it "truncates with options" do
      view.truncate("This is a string that will go longer then the default truncate length of 30", omission: "[...]").should eq "This is a string that wil[...]"
      view.truncate("Hello World!", length: 10).should eq "Hello W..."
      view.truncate("Hello World!", omission: "[...]", length: 10).should eq "Hello[...]"
      view.truncate("Hello Big World!", omission: "[...]", length: 13, separator: " ").should eq "Hello[...]"
      view.truncate("Hello Big World!", omission: "[...]", length: 14, separator: " ").should eq "Hello Big[...]"
      view.truncate("Hello Big World!", omission: "[...]", length: 15, separator: " ").should eq "Hello Big[...]"
    end

    it "truncates with link options" do
      view.truncate("Here is a long test and I need a continue to read link", length: 27) { view.link("Continue", "#") }.should eq "Here is a long test and ...<a href=\"#\">Continue</a>"
      view.test_truncate.should eq "Hello...<a href=\"#\">Continue</a>"
      view.truncate("Hello World", 12){ view.link "Continue", "#more" }.should eq "Hello World"
    end
  end
end
