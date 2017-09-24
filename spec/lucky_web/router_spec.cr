require "../../spec_helper"

describe LuckyWeb::Router do
  it "routes based on the method name and path" do
    LuckyWeb::Router.add :get, "/test", LuckyWeb::Action

    LuckyWeb::Router.find_action(:get, "/test").should_not be_nil
    LuckyWeb::Router.find_action("get", "/test").should_not be_nil
    LuckyWeb::Router.find_action(:post, "/test").should be_nil
  end
end
