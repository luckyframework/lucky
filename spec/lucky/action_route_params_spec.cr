require "../spec_helper"

include ContextHelper

private class TestAction < TestAction
  get "/test/:param_1/:param_2" do
    plain_text "test"
  end
end

describe "Automatically generated param helpers" do
  it "generates helpers for all route params" do
    action = TestAction.new(build_context, {"param_1" => "param_1_value", "param_2" => "param_2_value"})
    action.param_1.should eq "param_1_value"
    action.param_2.should eq "param_2_value"
    typeof(action.param_1).should eq String
    typeof(action.param_2).should eq String
  end
end

# Test for https://github.com/luckyframework/lucky/issues/928
private class TestRssFeedAction < TestAction
  get "/:test/feed.rss" do
    plain_text "rss #{test}"
  end
end

private class TestJsonFeedAction < TestAction
  get "/:other/feed.json" do
    plain_text "json #{other}"
  end
end

describe "Routes that differ in file extension only" do
  it "sets route params properly" do
    Lucky::Router.add :get, "/:test/feed.rss", TestRssFeedAction
    Lucky::Router.add :get, "/:other/feed.json", TestJsonFeedAction

    handler = Lucky::Router.find_action(:get, "/prefix/feed.json")
    if handler
      handler.params.should eq({"other" => "prefix"})
    else
      handler.should_not be_nil
    end
  end
end
