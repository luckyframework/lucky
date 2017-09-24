require "./spec_helper"

include ContextHelper

describe LuckyWeb::HttpMethodOverrideHandler do
  describe "#call" do
    it "leaves GET and POST as-is" do
      should_handle "GET", overridden_method: "", and_return: "GET"
      should_handle "POST", overridden_method: "", and_return: "POST"
    end

    it "overrides when POST with overridden PUT or DELETE" do
      should_handle "POST", overridden_method: "put", and_return: "PUT"
      should_handle "POST", overridden_method: "delete", and_return: "DELETE"
    end

    it "leaves as-is when GET with overriden method" do
      should_handle "GET", overridden_method: "delete", and_return: "GET"
    end
  end
end

private def should_handle(original_method, overridden_method, and_return expected_method)
  request = build_request original_method, body: "_method=#{overridden_method}"
  handler = LuckyWeb::HttpMethodOverrideHandler.new.call(build_context(request: request))
  request.method.should eq expected_method
end
