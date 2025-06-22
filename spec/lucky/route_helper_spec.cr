require "../spec_helper"

include ContextHelper

class TestSubdomainAction < TestAction
  get "/dashboard" do
    plain_text "admin dashboard"
  end
end

class TestParamAction < TestAction
  param page : Int32 = 1

  get "/posts" do
    plain_text "posts page #{page}"
  end
end

describe Lucky::RouteHelper do
  describe "url" do
    it "returns the host + path" do
      Lucky::RouteHelper.temp_config(base_uri: "example.com") do
        route = Lucky::RouteHelper.new(:get, "/users")

        route.url.should eq("example.com/users")
      end
    end

    it "returns the subdomain + host + path when subdomain is provided" do
      Lucky::RouteHelper.temp_config(base_uri: "https://example.com") do
        route = Lucky::RouteHelper.new(:get, "/users", "admin")

        route.url.should eq("https://admin.example.com/users")
      end
    end

    it "replaces existing subdomain when subdomain is provided" do
      Lucky::RouteHelper.temp_config(base_uri: "https://www.example.com") do
        route = Lucky::RouteHelper.new(:get, "/users", "admin")

        route.url.should eq("https://admin.example.com/users")
      end
    end

    it "handles port numbers correctly with subdomains" do
      Lucky::RouteHelper.temp_config(base_uri: "http://example.com:3000") do
        route = Lucky::RouteHelper.new(:get, "/users", "admin")

        route.url.should eq("http://admin.example.com:3000/users")
      end
    end

    it "works without subdomain when none is provided" do
      Lucky::RouteHelper.temp_config(base_uri: "https://example.com") do
        route = Lucky::RouteHelper.new(:get, "/users", nil)

        route.url.should eq("https://example.com/users")
      end
    end
  end

  describe ".with subdomain support" do
    it "generates URLs with subdomains using .with() method" do
      Lucky::RouteHelper.temp_config(base_uri: "https://example.com") do
        route = TestSubdomainAction.with(subdomain: "admin")

        route.url.should eq("https://admin.example.com/dashboard")
        route.path.should eq("/dashboard")
      end
    end

    it "generates URLs with subdomains and params using .with() method" do
      Lucky::RouteHelper.temp_config(base_uri: "https://example.com") do
        route = TestParamAction.with(page: 2, subdomain: "blog")

        route.url.should eq("https://blog.example.com/posts?page=2")
        route.path.should eq("/posts?page=2")
      end
    end

    it "generates URLs without subdomain when not specified in .with()" do
      Lucky::RouteHelper.temp_config(base_uri: "https://example.com") do
        route = TestSubdomainAction.with

        route.url.should eq("https://example.com/dashboard")
        route.path.should eq("/dashboard")
      end
    end

    it "handles anchors with subdomains" do
      Lucky::RouteHelper.temp_config(base_uri: "https://example.com") do
        route = TestSubdomainAction.with(subdomain: "admin", anchor: "top")

        route.url.should eq("https://admin.example.com/dashboard#top")
      end
    end

    it "replaces existing subdomain in base_uri when subdomain is specified" do
      Lucky::RouteHelper.temp_config(base_uri: "https://www.example.com") do
        route = TestSubdomainAction.with(subdomain: "admin")

        route.url.should eq("https://admin.example.com/dashboard")
      end
    end
  end
end
