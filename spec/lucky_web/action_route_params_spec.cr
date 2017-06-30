require "../../spec_helper"

private class TestAction < LuckyWeb::Action
  get "/test/:param_1/:param_2" do
    render_text "test"
  end
end

describe "Automatically generated param helpers" do
  it "generates helpers for all route params" do
    action = TestAction.new(context, {"param_1" => "param_1_value", "param_2" => "param_2_value"})
    action.param_1.should eq "param_1_value"
    action.param_2.should eq "param_2_value"
    typeof(action.param_1).should eq String
    typeof(action.param_2).should eq String
  end
end

private def context(path = "/")
  io = IO::Memory.new
  request = HTTP::Request.new("GET", path)
  response = HTTP::Server::Response.new(io)
  HTTP::Server::Context.new request, response
end

private def params
  {} of String => String
end
