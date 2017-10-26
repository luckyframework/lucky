require "../../spec_helper"

include ContextHelper

class CustomRoutes::Index < LuckyWeb::Action
  get "/so_custom" do
    render_text "test"
  end
end

class CustomRoutes::Put < LuckyWeb::Action
  put "/so_custom" do
    render_text "test"
  end
end

class CustomRoutes::Post < LuckyWeb::Action
  post "/so_custom" do
    render_text "test"
  end
end

class CustomRoutes::Delete < LuckyWeb::Action
  delete "/so_custom" do
    render_text "test"
  end
end

class Tests::IndexPage
  include LuckyWeb::Page

  render do
    text "Rendered from Tests::IndexPage"
  end
end

class Tests::Index < LuckyWeb::Action
  action do
    render
  end
end

class Tests::New < LuckyWeb::Action
  action do
    render_text "test"
  end
end

class Tests::Edit < LuckyWeb::Action
  action do
    render_text "test"
  end
end

class Tests::Show < LuckyWeb::Action
  action do
    render_text "test"
  end
end

class Tests::Delete < LuckyWeb::Action
  action do
    render_text "test"
  end
end

class Tests::Update < LuckyWeb::Action
  action do
    render_text "test"
  end
end

class Tests::Create < LuckyWeb::Action
  action do
    render_text "test"
  end
end

class PlainText::Index < LuckyWeb::Action
  action do
    render_text "plain"
  end
end

describe LuckyWeb::Action do
  describe "routing" do
    it "creates URL helpers for the resourceful actions" do
      Tests::Index.path.should eq "/tests"
      Tests::Index.route.should eq LuckyWeb::RouteHelper.new(:get, "/tests")
      Tests::New.path.should eq "/tests/new"
      Tests::New.route.should eq LuckyWeb::RouteHelper.new(:get, "/tests/new")
      Tests::Edit.path("test-id").should eq "/tests/test-id/edit"
      Tests::Edit.route("test-id").should eq LuckyWeb::RouteHelper.new(:get, "/tests/test-id/edit")
      Tests::Show.path("test-id").should eq "/tests/test-id"
      Tests::Show.route("test-id").should eq LuckyWeb::RouteHelper.new(:get, "/tests/test-id")
      Tests::Delete.path("test-id").should eq "/tests/test-id"
      Tests::Delete.route("test-id").should eq LuckyWeb::RouteHelper.new(:delete, "/tests/test-id")
      Tests::Update.path("test-id").should eq "/tests/test-id"
      Tests::Update.route("test-id").should eq LuckyWeb::RouteHelper.new(:put, "/tests/test-id")
      Tests::Create.path.should eq "/tests"
      Tests::Create.route.should eq LuckyWeb::RouteHelper.new(:post, "/tests")
    end

    it "adds routes to the router" do
      assert_route_added? LuckyWeb::Route.new :get, "/tests", Tests::Index
      assert_route_added? LuckyWeb::Route.new :get, "/tests/new", Tests::New
      assert_route_added? LuckyWeb::Route.new :get, "/tests/:id/edit", Tests::Edit
      assert_route_added? LuckyWeb::Route.new :get, "/tests/:id", Tests::Show
      assert_route_added? LuckyWeb::Route.new :delete, "/tests/:id", Tests::Delete
      assert_route_added? LuckyWeb::Route.new :put, "/tests/:id", Tests::Update
      assert_route_added? LuckyWeb::Route.new :post, "/tests", Tests::Create
    end

    it "allows setting custom routes" do
      assert_route_not_added? LuckyWeb::Route.new :get, "/custom_routes", CustomRoutes::Index

      assert_route_added? LuckyWeb::Route.new :get, "/so_custom", CustomRoutes::Index
      assert_route_added? LuckyWeb::Route.new :put, "/so_custom", CustomRoutes::Put
      assert_route_added? LuckyWeb::Route.new :post, "/so_custom", CustomRoutes::Post
      assert_route_added? LuckyWeb::Route.new :delete, "/so_custom", CustomRoutes::Delete
    end
  end

  describe "rendering" do
    it "renders plain text" do
      response = PlainText::Index.new(build_context, params).call
      response.body.should eq "plain"
      response.content_type.should eq "text/plain"
    end

    it "infer the correct HTML page to render" do
      response = Tests::Index.new(build_context, params).call
      response.body.should contain "Rendered from Tests::IndexPage"
      response.content_type.should eq "text/html"
    end
  end

  describe "params" do
    it "can get params" do
      action = PlainText::Index.new(build_context(path: "/?q=test"), params)
      action.params.get(:q).should eq "test"
    end
  end
end

private def assert_route_added?(expected_route)
  LuckyWeb::Router.routes.should contain(expected_route)
end

private def assert_route_not_added?(expected_route)
  LuckyWeb::Router.routes.should_not contain(expected_route)
end
