require "../../spec_helper"

class Admin::MultiWord::Users::Show < LuckyWeb::Action
  action do
    render_text "plain"
  end
end

describe LuckyWeb::Action do
  describe "routing" do
    it "creates URL helpers for the resourceful actions" do
      Admin::MultiWord::Users::Show
        .path("foo")
        .should eq "/admin/multi_word/users/foo"
      Admin::MultiWord::Users::Show
        .route("foo")
        .should eq LuckyWeb::RouteHelper.new(:get, "/admin/multi_word/users/foo")
    end

    it "adds routes to the router" do
      assert_route_added? LuckyWeb::Route.new :get, "/admin/multi_word/users/:id", Admin::MultiWord::Users::Show
    end
  end
end

private def assert_route_added?(expected_route)
  LuckyWeb::Router.routes.should contain(expected_route)
end

private def assert_route_not_added?(expected_route)
  LuckyWeb::Router.routes.should_not contain(expected_route)
end
