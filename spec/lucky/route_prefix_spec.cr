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
  route_prefix "/parent_api"
end

class ChildApiWithParentPrefix < TestApiPrefixAction
  get "/has_parent_prefix" do
    plain_text "child route prefixed"
  end
end

class ChildApiWithOwnPrefix < TestApiPrefixAction
  route_prefix "/child_api"

  get "/has_own_prefix" do
    plain_text "child route prefixed"
  end
end

module ApiPrefixModule
  macro included
    route_prefix "/module_prefix"
  end
end

class ActionIncludingModulePrefix < TestAction
  include ApiPrefixModule

  get "/has_module_prefix" do
    plain_text "child route prefixed"
  end
end

class ActionNotIncludingModulePrefix < TestAction
  get "/no_prefix" do
    plain_text "no prefix"
  end
end

describe "prefixing routes" do
  it "prefixes the URL helpers for the resourceful actions" do
    assert_route_added?(:get, "/api/v1/prefixed_get", PrefixedActions)
    assert_route_added?(:put, "/api/v1/prefixed_put/:id", PrefixedActions)
    assert_route_added?(:post, "/api/v1/prefixed_post/:id", PrefixedActions)
    assert_route_added?(:patch, "/api/v1/prefixed_patch/:id", PrefixedActions)
    assert_route_added?(:trace, "/api/v1/prefixed_trace/:id", PrefixedActions)
    assert_route_added?(:delete, "/api/v1/prefixed_delete/:id", PrefixedActions)
    assert_route_added?(:options, "/api/v1/prefixed_match_options", PrefixedActions)
  end

  it "correctly prefixes through inheritance" do
    assert_route_added?(:get, "/parent_api/has_parent_prefix", ChildApiWithParentPrefix)
    assert_route_added?(:get, "/child_api/has_own_prefix", ChildApiWithOwnPrefix)
  end

  it "correctly prefixes action through included modules" do
    assert_route_added?(:get, "/module_prefix/has_module_prefix", ActionIncludingModulePrefix)
    assert_route_added?(:get, "/no_prefix", ActionNotIncludingModulePrefix)
  end
end
