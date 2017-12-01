require "./text_helpers_spec"

describe Lucky::TextHelpers do
  describe "pluralize" do
    it "pluralizes words" do
      view.pluralize(1, "count").to_s.should eq "1 count"
      view.pluralize(2, "count").to_s.should eq "2 counts"
      view.pluralize("1", "count").to_s.should eq "1 count"
      view.pluralize("2", "count").to_s.should eq "2 counts"
      view.pluralize("1,066", "count").to_s.should eq "1,066 counts"
      view.pluralize("1.25", "count").to_s.should eq "1.25 counts"
      view.pluralize("1.0", "count").to_s.should eq "1.0 count"
      view.pluralize("1.00", "count").to_s.should eq "1.00 count"
      view.pluralize(2, "count", "counters").to_s.should eq "2 counters"
      view.pluralize(nil, "count", "counters").to_s.should eq "0 counters"
      view.pluralize(2, "count", plural: "counters").to_s.should eq "2 counters"
      view.pluralize(nil, "count", plural: "counters").to_s.should eq "0 counters"
      view.pluralize(2, "person").to_s.should eq "2 people"
      view.pluralize(10, "buffalo").to_s.should eq "10 buffaloes"
      view.pluralize(1, "berry").to_s.should eq "1 berry"
      view.pluralize(12, "berry").to_s.should eq "12 berries"
    end
  end
end
