require "../../spec_helper"

describe Lucky::Router do
  # TODO: use this once there's a way to scope to just this block
  #Spec.before_each do
  #  Lucky::Router.reset!
  #end

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

  it "finds a fallback route" do
    Lucky::Router.reset!
    Lucky::Router.add_fallback(Lucky::Action)

    Lucky::Router.find_action(:get, "/test").should_not be_nil
    Lucky::Router.find_action(:get, "/test").should be_a Lucky::FallbackRoute
  end
end
