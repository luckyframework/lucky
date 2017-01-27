require "../../spec_helper"

class Tests::IndexPage
  def render
    "Rendered from Tests::IndexPage"
  end
end

class Tests::IndexAction < LuckyWeb::Action
  def call
    render
  end
end

class Tests::NewAction < LuckyWeb::Action
  def call
    render_text "test"
  end
end

class Tests::ShowAction < LuckyWeb::Action
  def call
    render_text "test"
  end
end

class PlainText::IndexAction < LuckyWeb::Action
  def call
    render_text "plain"
  end
end

describe LuckyWeb::Action do
  describe "routing" do
    it "creates route helpers for the resourceful actions" do
      Tests::IndexAction.route.should eq "/tests"
      Tests::NewAction.route.should eq "/tests/new"
      Tests::ShowAction.route("test-id").should eq "/tests/test-id"
    end

    it "adds routes to the router" do
      assert_route_added? LuckyWeb::Route.new :get, "/tests", Tests::IndexAction
      assert_route_added? LuckyWeb::Route.new :get, "/tests/new", Tests::NewAction
      assert_route_added? LuckyWeb::Route.new :get, "/tests/:id", Tests::ShowAction
    end
  end

  describe "rendering" do
    it "renders plain text" do
      response = PlainText::IndexAction.new(context, params).call
      response.body.should eq "plain"
      response.content_type.should eq "text/plain"
    end

    it "infer the correct HTML page to render" do
      response = Tests::IndexAction.new(context, params).call
      response.body.should eq "Rendered from Tests::IndexPage"
      response.content_type.should eq "text/html"
    end
  end

  describe "query params" do
    it "can get query params from a string or a symbol" do
      action = PlainText::IndexAction.new(context(path: "/?q=test"), params)
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

private def context(path = "/")
  io = IO::Memory.new
  request = HTTP::Request.new("GET", path)
  response = HTTP::Server::Response.new(io)
  HTTP::Server::Context.new request, response
end

private def params
  {} of String => String
end
