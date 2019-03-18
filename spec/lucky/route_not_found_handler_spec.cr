require "../spec_helper"

include ContextHelper

class SampleFallbackAction::Index < Lucky::Action
  fallback do
    text "Last chance"
  end
end

describe Lucky::RouteNotFoundHandler do
  it "raises a Lucky::RouteNotFoundError" do
    context = build_context(path: "/foo/bar")
    context.request.method = "POST"

    expect_raises(Lucky::RouteNotFoundError, "POST /foo/bar") do
      error_handler = Lucky::RouteNotFoundHandler.new
      error_handler.next = ->(_ctx : HTTP::Server::Context) {}
      error_handler.call(context)
    end
  end

  it "takes an optional fallback action" do
    context = build_context(path: "/non-existent")
    context.request.method = "GET"

    handler = Lucky::RouteNotFoundHandler.new(fallback: SampleFallbackAction::Index)
    handler.next = ->(_ctx : HTTP::Server::Context) {}
    handler.call(context)
  end
end
