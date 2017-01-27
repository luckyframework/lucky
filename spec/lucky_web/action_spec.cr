require "../../spec_helper"

class CustomRoutes::Index < LuckyWeb::Action
  get "/so_custom" do
    render_text "test"
  end
end

class Tests::IndexPage
  def render
    "Rendered from Tests::IndexPage"
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

class Tests::Show < LuckyWeb::Action
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
    it "creates route helpers for the resourceful actions" do
      Tests::Index.route.should eq "/tests"
      Tests::New.route.should eq "/tests/new"
      Tests::Show.route("test-id").should eq "/tests/test-id"
    end

    it "adds routes to the router" do
      assert_route_added? LuckyWeb::Route.new :get, "/tests", Tests::Index
      assert_route_added? LuckyWeb::Route.new :get, "/tests/new", Tests::New
      assert_route_added? LuckyWeb::Route.new :get, "/tests/:id", Tests::Show
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

  describe "query params" do
    it "can get query params from a string or a symbol" do
      action = PlainText::Index.new(context(path: "/?q=test"), params)
      action.query_param(:q).should eq "test"
      action.query_param("q").should eq "test"
      action.query_param?(:not_there).should eq nil
      action.query_param?("not_there").should eq nil
    end
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
