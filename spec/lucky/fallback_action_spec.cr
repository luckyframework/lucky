require "../spec_helper"

include ContextHelper

# TestFallbackAction::Index is defined in spec/support/test_fallback_action.cr
# so that it can be used in other tests without causing conflicts.
describe "fallback routing" do
  it "renders from a fallback" do
    response = TestFallbackAction::Index.new(build_context, params).call
    response.body.should eq "You found me"
    response.status.should eq 200
  end

  it "does not generate route helpers" do
    TestFallbackAction::Index.responds_to?(:route).should be_false
    TestFallbackAction::Index.responds_to?(:with).should be_false
    TestFallbackAction::Index.responds_to?(:url).should be_false
    TestFallbackAction::Index.responds_to?(:path).should be_false
    TestFallbackAction::Index.responds_to?(:url_without_query_params).should be_false
  end
end
