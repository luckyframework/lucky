require "../spec_helper"

class PrefixedActions < TestAction
  route_prefix "/api/v1"

  get "/prefixed_get" do
    plain_text "im prefixed!"
  end

  post "/prefixed_post/:id" do
    plain_text "im prefixed!"
  end

  put "/prefixed_put/:id" do
    plain_text "im prefixed!"
  end

  patch "/prefixed_patch/:id" do
    plain_text "im prefixed!"
  end

  trace "/prefixed_trace/:id" do
    plain_text "im prefixed!"
  end

  delete "/prefixed_delete/:id" do
    plain_text "im prefixed!"
  end

  match :options, "/prefixed_match_options" do
    plain_text "im prefixed!"
  end
end

abstract class TestApiPrefixAction < TestAction
  route_prefix "/parent-api"
end

class ChildApiWithParentPrefix < TestApiPrefixAction
  get "/has-parent-prefix" do
    plain_text "child route prefixed"
  end
end

class ChildApiWithOwnPrefix < TestApiPrefixAction
  route_prefix "/child-api"

  get "/has-own-prefix" do
    plain_text "child route prefixed"
  end
end

module ApiPrefixModule
  macro included
    route_prefix "/module-prefix"
  end
end

class ActionIncludingModulePrefix < TestAction
  include ApiPrefixModule

  get "/has-module-prefix" do
    plain_text "child route prefixed"
  end
end

class ActionNotIncludingModulePrefix < TestAction
  get "/no-prefix" do
    plain_text "no prefix"
  end
end

describe "prefixing routes" do
  it "prefixes the URL helpers for the resourceful actions" do
    assert_route_added? Lucky::Route.new :get, "/api/v1/prefixed_get", PrefixedActions
    assert_route_added? Lucky::Route.new :put, "/api/v1/prefixed_put/:id", PrefixedActions
    assert_route_added? Lucky::Route.new :post, "/api/v1/prefixed_post/:id", PrefixedActions
    assert_route_added? Lucky::Route.new :patch, "/api/v1/prefixed_patch/:id", PrefixedActions
    assert_route_added? Lucky::Route.new :trace, "/api/v1/prefixed_trace/:id", PrefixedActions
    assert_route_added? Lucky::Route.new :delete, "/api/v1/prefixed_delete/:id", PrefixedActions
    assert_route_added? Lucky::Route.new :options, "/api/v1/prefixed_match_options", PrefixedActions
  end

  it "correctly prefixes through inheritance" do
    assert_route_added? Lucky::Route.new :get, "/parent-api/has-parent-prefix", ChildApiWithParentPrefix
    assert_route_added? Lucky::Route.new :get, "/child-api/has-own-prefix", ChildApiWithOwnPrefix
  end

  it "correctly prefixes action through included modules" do
    assert_route_added? Lucky::Route.new :get, "/module-prefix/has-module-prefix", ActionIncludingModulePrefix
    assert_route_added? Lucky::Route.new :get, "/no-prefix", ActionNotIncludingModulePrefix
  end
end

private def assert_route_added?(expected_route)
  Lucky::Router.routes.should contain(expected_route)
end
