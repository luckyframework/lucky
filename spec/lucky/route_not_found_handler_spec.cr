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

  it "has the fallback_action set from a fallback route" do
    Lucky::RouteNotFoundHandler.fallback_action.should eq SampleFallbackAction::Index
  end
end
