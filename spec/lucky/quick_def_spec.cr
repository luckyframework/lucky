require "../spec_helper"

private class QuickDefClass
  quick_def :page_title, "My page title"
  quick_def page_title_without_symbol, "My page title"
end

describe "Object.quick_def" do
  it "creates an instance method" do
    QuickDefClass.new.page_title.should eq "My page title"
    QuickDefClass.new.page_title_without_symbol.should eq "My page title"
  end
end
