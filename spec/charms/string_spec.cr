require "../spec_helper"

describe "String charm" do
  describe "squish" do
    it "squishes the text by removing ascii/unicode whitespace" do
      og_string = "\u1680 \v\v\v\v\v\r\r\r\r hello foo bar\n\u00A0\t\t\u00A0\u1680\u1680   "

      og_string.squish.should eq("hello foo bar")
    end
  end
end
