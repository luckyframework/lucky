require "../spec_helper"

describe Lucky::RouteHelper do
  describe "url" do
    it "returns the host + path" do
      Lucky::RouteHelper.temp_config(base_uri: "example.com") do
        route = Lucky::RouteHelper.new(:get, "/users")

        route.url.should eq("example.com/users")
      end
    end
  end
end
