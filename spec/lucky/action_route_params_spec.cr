require "../spec_helper"

include ContextHelper

private class TestAction < Lucky::Action
  get "/test/:param_1/:param_2" do
    text "test"
  end
end

private class TestWithFileExtensionAction < Lucky::Action
  get "/test/:param_1.csv" do
    text "test"
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

describe "Testing params that end with file extension" do
  it "generates helpers for the param name" do
    action = TestWithFileExtensionAction.new(build_context, {"param_1" => "param_1_value"})
    action.param_1.should eq "param_1_value"
    typeof(action.param_1).should eq String
  end
end
