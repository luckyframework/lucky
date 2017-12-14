require "../spec_helper"

describe Lucky::RouteHelper do
  describe "url" do
    it "returns the host + path" do
      Lucky::RouteHelper.configure { settings.domain = "example.com" }

      route = Lucky::RouteHelper.new(:get, "/users")

      route.url.should eq("example.com/users")
    end
  end
end
