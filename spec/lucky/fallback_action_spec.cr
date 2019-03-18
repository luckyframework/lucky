require "../../spec_helper"

include ContextHelper

class Rendering::FallbackRoute < Lucky::Action
  fallback do
    text "Hey, you found me!"
  end
end

describe "fallback routing" do
  it "renders from a fallback" do
    response = Rendering::FallbackRoute.new(build_context, params).call
    response.body.should eq "Hey, you found me!"
    response.status.should eq 200
  end

  it "does not generate route helpers" do
    Rendering::FallbackRoute.responds_to?(:route).should be_false
    Rendering::FallbackRoute.responds_to?(:with).should be_false
    Rendering::FallbackRoute.responds_to?(:url).should be_false
    Rendering::FallbackRoute.responds_to?(:path).should be_false
    Rendering::FallbackRoute.responds_to?(:url_without_query_params).should be_false
  end
end
