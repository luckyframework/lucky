require "../spec_helper"

include ContextHelper

describe Lucky::HttpMethodOverrideHandler do
  describe "#call" do
    it "leaves GET and POST as-is" do
      should_handle "GET", overridden_method: "", and_return: "GET"
      should_handle "POST", overridden_method: "", and_return: "POST"
    end

    it "overrides when POST with overridden PATCH, PUT or DELETE" do
      should_handle "POST", overridden_method: "patch", and_return: "PATCH"
      should_handle "POST", overridden_method: "put", and_return: "PUT"
      should_handle "POST", overridden_method: "delete", and_return: "DELETE"
    end

    it "leaves as-is when GET with overridden method" do
      should_handle "GET", overridden_method: "delete", and_return: "GET"
    end

    it "works when there is no overridden method" do
      should_handle "GET", overridden_method: nil, and_return: "GET"
    end

    it "continues if request body contains malformed json" do
      request = build_request "GET", body: "{ \"bad_json\": 123", content_type: "application/json"

      Lucky::HttpMethodOverrideHandler.new.call(build_context(request: request))

      request.method.should eq "GET"
    end
  end
end

private def should_handle(original_method, overridden_method, and_return expected_method)
  request = if overridden_method
              build_request original_method, body: "_method=#{overridden_method}"
            else
              build_request original_method
            end
  Lucky::HttpMethodOverrideHandler.new.call(build_context(request: request))
  request.method.should eq expected_method
end
