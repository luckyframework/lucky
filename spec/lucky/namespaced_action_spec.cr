require "../spec_helper"

class Admin::MultiWord::Users::Show < TestAction
  route do
    plain_text "plain"
  end
end

describe Lucky::Action do
  describe "routing" do
    it "creates URL helpers for the resourceful actions" do
      Admin::MultiWord::Users::Show
        .path("foo")
        .should eq "/admin/multi_word/users/foo"
      Admin::MultiWord::Users::Show
        .with("foo")
        .should eq Lucky::RouteHelper.new(:get, "/admin/multi_word/users/foo")
    end

    it "adds routes to the router" do
      assert_route_added? Lucky::Route.new :get, "/admin/multi_word/users/:user_id", Admin::MultiWord::Users::Show
    end
  end
end

private def assert_route_added?(expected_route)
  Lucky::Router.routes.should contain(expected_route)
end

private def assert_route_not_added?(expected_route)
  Lucky::Router.routes.should_not contain(expected_route)
end
