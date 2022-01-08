require "../spec_helper"

class Admin::MultiWord::Users::Show < TestAction
  get "/admin/multi_word/users/:user_id" do
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
      assert_route_added?(:get, "/admin/multi_word/users/:user_id", Admin::MultiWord::Users::Show)
    end
  end
end
