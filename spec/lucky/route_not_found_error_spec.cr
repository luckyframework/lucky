require "../spec_helper"

include ContextHelper

describe Lucky::RouteNotFoundError do
  it "has getter for the context" do
    context = build_context(path: "/foo/bar")

    error = Lucky::RouteNotFoundError.new(context)

    error.context.should eq context
  end
end
