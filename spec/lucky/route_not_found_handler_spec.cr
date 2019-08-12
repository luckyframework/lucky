require "../spec_helper"

include ContextHelper

class SampleFallbackAction::Index < TestAction
  fallback do
    plain_text "Last chance"
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

  it "has the fallback_action set from a fallback route" do
    Lucky::RouteNotFoundHandler.fallback_action.should eq SampleFallbackAction::Index
  end

  it "responds with a fallback action" do
    output = IO::Memory.new
    context = build_context_with_io(output, path: "/non-existent")
    context.request.method = "GET"
    handler = Lucky::RouteNotFoundHandler.new
    handler.next = ->(_ctx : HTTP::Server::Context) {}

    handler.call(context)

    context.response.close
    output.to_s.should contain "Last chance"
  end

  it "still raises a Lucky::RouteNotFoundError for non GET requests" do
    output = IO::Memory.new
    context = build_context_with_io(output, path: "/non-existent")
    context.request.method = "POST"
    handler = Lucky::RouteNotFoundHandler.new
    handler.next = ->(_ctx : HTTP::Server::Context) {}

    expect_raises(Lucky::RouteNotFoundError) do
      handler.call(context)
    end
  end
end
