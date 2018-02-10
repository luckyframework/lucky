require "../spec_helper"

include ContextHelper

describe Lucky::RouteNotFoundHandler do
  it "raises a Lucky::RouteNotFoundError" do
    context = build_context(path: "/foo/bar")
    context.request.method = "POST"

    expect_raises(Lucky::RouteNotFoundError, "POST /foo/bar") do
      error_handler = Lucky::RouteNotFoundHandler.new
      error_handler.next = ->(ctx : HTTP::Server::Context) {}
      error_handler.call(context)
    end
  end
end
