require "../../spec_helper"

describe LuckyWeb::Router do
  it "routes based on the method name and path" do
    LuckyWeb::Router.add :get, "/test", LuckyWeb::Action

    LuckyWeb::Router.find_action(:get, "/test").found?.should be_true
    LuckyWeb::Router.find_action(:post, "/test").found?.should be_false
  end
end
