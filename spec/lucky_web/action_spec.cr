require "../../spec_helper"

class CustomRoutes::Index < LuckyWeb::Action
  get "/so_custom" do
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
      assert_route_added? LuckyWeb::Route.new :get, "/so_custom", CustomRoutes::Index
      assert_route_not_added? LuckyWeb::Route.new :get, "/custom_routes", CustomRoutes::Index
    end
  end

  describe "rendering" do
    it "renders plain text" do
      response = PlainText::Index.new(context, params).call
      response.body.should eq "plain"
      response.content_type.should eq "text/plain"
    end

    it "infer the correct HTML page to render" do
      response = Tests::Index.new(context, params).call
      response.body.should eq "Rendered from Tests::IndexPage"
      response.content_type.should eq "text/html"
    end
  end

  describe "params" do
    it "can get params" do
      action = PlainText::Index.new(context(path: "/?q=test"), params)
      action.params.get(:q).should eq "test"
    end
  end

  it "redirects" do
    action = Tests::Index.new(context, params)
    action.redirect to: "/somewhere"
    action.context.response.headers["Location"].should eq "/somewhere"
    action.context.response.status_code.should eq 302

    action = Tests::Index.new(context, params)
    action.redirect to: Tests::Index.route
    action.context.response.headers["Location"].should eq Tests::Index.path
    action.context.response.status_code.should eq 302
  end

  it "redirects with custom status" do
    action = Tests::Index.new(context, params)
    action.redirect to: "/somewhere", status: 301
    action.context.response.headers["Location"].should eq "/somewhere"
    action.context.response.status_code.should eq 301
  end
end

private def assert_route_added?(expected_route)
  LuckyWeb::Router.routes.should contain(expected_route)
end

private def assert_route_not_added?(expected_route)
  LuckyWeb::Router.routes.should_not contain(expected_route)
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
