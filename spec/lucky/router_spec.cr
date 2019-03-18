require "../../spec_helper"

describe Lucky::Router do

  it "routes based on the method name and path" do
    Lucky::Router.reset!
    Lucky::Router.add :get, "/test", Lucky::Action

    Lucky::Router.find_action(:get, "/test").should_not be_nil
    Lucky::Router.find_action("get", "/test").should_not be_nil
    Lucky::Router.find_action(:post, "/test").should be_nil
  end

  it "finds the associated get route by a head method" do
    Lucky::Router.reset!
    Lucky::Router.add :get, "/test", Lucky::Action

    Lucky::Router.find_action(:head, "/test").should_not be_nil
    Lucky::Router.find_action("head", "/test").should_not be_nil
  end
end
