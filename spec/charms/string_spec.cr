require "../spec_helper"

describe "String charm" do
  describe "squish" do
    it "squishes the text by removing newlines and extra whitespace" do
      og_string = " foo   bar    \n   \t   boo"

      og_string.squish.should eq("foo bar boo")
      og_string.should eq(" foo   bar    \n   \t   boo")
    end
  end
end
