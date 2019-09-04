require "./text_helpers_spec"

describe Lucky::TextHelpers do
  describe "pluralize" do
    it "pluralizes words" do
      view.pluralize(1, "count").should eq "1 count"
      view.pluralize(2, "count").should eq "2 counts"
      view.pluralize(1000000000000, "count").should eq "1000000000000 counts"
      view.pluralize("1", "count").should eq "1 count"
      view.pluralize("2", "count").should eq "2 counts"
      view.pluralize("1,066", "count").should eq "1,066 counts"
      view.pluralize("1.25", "count").should eq "1.25 counts"
      view.pluralize("1.0", "count").should eq "1.0 count"
      view.pluralize("1.00", "count").should eq "1.00 count"
      view.pluralize(2, "count", "counters").should eq "2 counters"
      view.pluralize(nil, "count", "counters").should eq "0 counters"
      view.pluralize(2, "count", plural: "counters").should eq "2 counters"
      view.pluralize(nil, "count", plural: "counters").should eq "0 counters"
      view.pluralize(2, "person").should eq "2 people"
      view.pluralize(10, "buffalo").should eq "10 buffaloes"
      view.pluralize(1, "berry").should eq "1 berry"
      view.pluralize(12, "berry").should eq "12 berries"
    end
  end
end
