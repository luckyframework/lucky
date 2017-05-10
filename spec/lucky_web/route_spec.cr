require "../../spec_helper"

describe LuckyWeb::Route do
  it "builds route paths" do
    LuckyWeb::Route.build_route_path(:get, "/test").should eq "get/test"
  end
end
