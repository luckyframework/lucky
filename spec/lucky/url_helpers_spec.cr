require "../spec_helper"

include ContextHelper

describe Lucky::UrlHelpers do
  describe "#current_page?" do
    context "given a string" do
      it "tests if a path matches the request path or not" do
        view_for("/").current_page?("/").should be_true
        view_for("/action").current_page?("/gum").should be_false
        view_for("/action").current_page?("/action").should be_true
        view_for("/action").current_page?("/action/").should be_true
        view_for("/action/").current_page?("/action").should be_true
        view_for("/action/").current_page?("/action/").should be_true
      end

      it "tests if the path of a url matches request path or not" do
        view_for("/")
          .current_page?("https://example.com/")
          .should be_true
        view_for("/action")
          .current_page?("https://example.com/action")
          .should be_true
        view_for("/action", host_with_port: "example.io")
          .current_page?("https://example.com/action")
          .should be_false
        view_for("/action", host_with_port: "example.com:3000")
          .current_page?("https://example.com/action")
          .should be_false
        view_for("/action", host_with_port: "example.com:3000")
          .current_page?("https://example.com:3000/action")
          .should be_true
        view_for("/action", host_with_port: "example.com:3000")
          .current_page?("http://example.com:3000/action")
          .should be_true
      end

      it "only tests positive for get and head requests" do
        view_for("/get", "GET").current_page?("/get").should be_true
        view_for("/head", "HEAD").current_page?("/head").should be_true
        view_for("/post", "POST").current_page?("/post").should be_false
        view_for("/put", "PUT").current_page?("/put").should be_false
        view_for("/patch", "PATCH").current_page?("/patch").should be_false
        view_for("/delete", "DELETE").current_page?("/delete").should be_false
      end

      it "ignores query parameters by default" do
        view_for("/action?order=desc&page=1").current_page?("/action")
          .should be_true
        view_for("/action").current_page?("/action?order=desc&page=1")
          .should be_true
        view_for("/action?order=desc&page=1").current_page?("/action/123")
          .should be_false
      end

      it "deals with escaped characters in query params" do
        view_for("/pages?description=Some%20d%C3%A9scription")
          .current_page?("/pages?description=Some déscription", check_query_params: true)
          .should be_true
        view_for("/pages?description=Some%20d%C3%A9scription")
          .current_page?("/pages?description=Some%20d%C3%A9scription", check_query_params: true)
          .should be_true
      end

      it "checks query params if explicitly required" do
        view_for("/action?order=desc&page=1")
          .current_page?("/action?order=desc&page=1", check_query_params: true)
          .should be_true
        view_for("/action")
          .current_page?("/action", check_query_params: true)
          .should be_true
        view_for("/action")
          .current_page?("/action?order=desc&page=1", check_query_params: true)
          .should be_false
        view_for("/action?order=desc&page=1")
          .current_page?("/action", check_query_params: true)
          .should be_false
      end

      it "does not care about the order of query params" do
        view_for("/action?order=desc&page=1")
          .current_page?("/action?order=desc&page=1", check_query_params: true)
          .should be_true
        view_for("/action?order=desc&page=1")
          .current_page?("/action?page=1&order=desc", check_query_params: true)
          .should be_true
      end

      it "ignores anchors" do
        view_for("/pages/123").current_page?("/pages/123#section")
          .should be_true
        view_for("/pages/123#section").current_page?("/pages/123")
          .should be_true
        view_for("/pages/123#section").current_page?("/pages/123#section")
          .should be_true
        view_for("/pages/123")
          .current_page?("/pages/123#section", check_query_params: true)
          .should be_true
      end
    end

    context "given a browser action" do
      it "tests if the path matches or not" do
        view_for("/pages/123").current_page?(Pages::Show.with(123))
          .should be_true
        view_for("/pages/123").current_page?(Pages::Show.with(12))
          .should be_false
        view_for("/pages").current_page?(Pages::Index)
          .should be_true
        view_for("/pages")
          .current_page?(Pages::Index.with(page: 2))
          .should be_true
        view_for("/pages?page=2")
          .current_page?(Pages::Index)
          .should be_true
      end

      it "checks query params if explicitly required" do
        view_for("/pages")
          .current_page?(Pages::Index, check_query_params: true)
          .should be_true
        view_for("/pages?page=2")
          .current_page?(Pages::Index.with(page: 2), check_query_params: true)
          .should be_true
        view_for("/pages")
          .current_page?(Pages::Index.with(page: 2), check_query_params: true)
          .should be_false
        view_for("/pages?page=2")
          .current_page?(Pages::Index, check_query_params: true)
          .should be_false
      end

      it "ignores anchors" do
        view_for("/pages/123")
          .current_page?(Pages::Show.with(123, anchor: "section"))
          .should be_true
        view_for("/pages/123#section")
          .current_page?(Pages::Show.with(123))
          .should be_true
        view_for("/pages/123#section")
          .current_page?(Pages::Show.with(123, anchor: "section"))
          .should be_true
        view_for("/pages/123")
          .current_page?(Pages::Show.with(123, anchor: "section"), check_query_params: true)
          .should be_true
      end
    end
  end

  describe "#previous_url" do
    it "returns the previous url from referer header when present" do
      view_for("/pages/456", headers: {"Referer" => "http://luckyframework.org/pages/123"})
        .previous_url(Pages::Index)
        .should eq "http://luckyframework.org/pages/123"
    end

    it "falls back to passed Lucky::Action when referer is the current page" do
      view_for("/pages/456", headers: {"Referer" => "http://luckyframework.org/pages/456"})
        .previous_url(Pages::Index)
        .should eq "/pages"
    end

    it "falls back to passed Lucky::Action when referer header is not present" do
      view_for("/pages/123")
        .previous_url(Pages::Index)
        .should eq "/pages"
    end

    it "falls back to passed Lucky::RouteHelper when referer header is not present" do
      view_for("/pages/123")
        .previous_url(Pages::Show.with(456))
        .should eq "/pages/456"
    end
  end
end

private def view_for(
  path : String,
  method : String = "GET",
  host_with_port : String = "example.com",
  headers : Hash(String, String) = {} of String => String
)
  request = HTTP::Request.new(method, path)
  request.headers["Host"] = host_with_port
  headers.each do |header, value|
    request.headers[header] = value
  end
  TestPage.new(build_context(path: path, request: request))
end

private class TestPage
  include Lucky::HTMLPage
end

class Pages::Index < TestAction
  param page : Int32 = 1

  get "/pages" do
    plain_text "I'm just a list of pages"
  end
end

class Pages::Show < TestAction
  get "/pages/:id" do
    plain_text "I'm just a page"
  end
end
