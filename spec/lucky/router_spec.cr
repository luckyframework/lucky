require "../spec_helper"

describe Lucky::Router do
  it "routes based on the method name and path" do
    Lucky::Router.add :get, "/test", Lucky::Action

    Lucky::Router.find_action(:get, "/test").should_not be_nil
    Lucky::Router.find_action("get", "/test").should_not be_nil
    Lucky::Router.find_action(:post, "/test").should be_nil
  end

  it "finds the associated get route by a head method" do
    Lucky::Router.add :get, "/test", Lucky::Action

    Lucky::Router.find_action(:head, "/test").should_not be_nil
    Lucky::Router.find_action("head", "/test").should_not be_nil
  end

  it "finds the route with an optional parts" do
    Lucky::Router.add :get, "/complex_posts/:required/?:optional_1/?:optional_2", Lucky::Action

    Lucky::Router.find_action(:get, "/complex_posts/1/2/3").should_not be_nil
    Lucky::Router.find_action(:get, "/complex_posts/1/2").should_not be_nil
    Lucky::Router.find_action(:get, "/complex_posts/1").should_not be_nil
  end
end
