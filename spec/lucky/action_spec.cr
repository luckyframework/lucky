require "../spec_helper"

include ContextHelper

class CustomRoutes::Index < TestAction
  get "/so_custom" do
    plain_text "test"
  end
end

class CustomRoutes::Put < TestAction
  put "/so_custom" do
    plain_text "test"
  end
end

class CustomRoutes::Post < TestAction
  post "/so_custom" do
    plain_text "test"
  end
end

class CustomRoutes::Patch < TestAction
  patch "/so_custom" do
    plain_text "test"
  end
end

class CustomRoutes::Trace < TestAction
  trace "/so_custom" do
    plain_text "test"
  end
end

class CustomRoutes::Delete < TestAction
  delete "/so_custom" do
    plain_text "test"
  end
end

class CustomRoutes::Match < TestAction
  match :options, "/so_custom" do
    plain_text "test"
  end
end

class Tests::IndexPage
  include Lucky::HTMLPage

  def render
    text "Rendered from Tests::IndexPage"
  end
end

class Tests::Index < TestAction
  route do
    html
  end
end

class Tests::New < TestAction
  route do
    plain_text "test"
  end
end

class Tests::Edit < TestAction
  route do
    plain_text "test"
  end
end

class Tests::Show < TestAction
  route do
    plain_text "test"
  end
end

class Tests::Delete < TestAction
  route do
    plain_text "test"
  end
end

class Tests::Update < TestAction
  route do
    plain_text "test"
  end
end

class Tests::Create < TestAction
  route do
    plain_text "test"
  end
end

class PlainText::Index < TestAction
  route do
    plain_text "plain"
  end
end

class RequiredParams::Index < TestAction
  param required_page : Int32
  # This is to test that the default value of 'false' is not treated as 'nil'
  param bool_with_false_default : Bool = false

  route do
    plain_text "required param: #{required_page} #{bool_with_false_default}"
  end
end

abstract class BaseActionWithParams < TestAction
  param inherit_me : String
end

class InheritedParams::Index < BaseActionWithParams
  route do
    plain_text "inherited param: #{inherit_me}"
  end
end

class OptionalParams::Index < TestAction
  param page : Int32?
  param with_default : String? = "default"
  param with_int_default : Int32? = 1
  param with_int_never_nil : Int32 = 1337
  # This is to test that the default value of 'false' is not treated as 'nil'
  param bool_with_false_default : Bool? = false
  # This is to test that an explicit 'nil' can be assigned for nilable types
  param nilable_with_explicit_nil : Int32? = nil

  route do
    plain_text "optional param: #{page} #{with_int_default} #{with_int_never_nil}"
  end
end

class ParamsWithDefaultParamsLast < TestAction
  param has_default : String = "default"
  param has_nil_default : String?
  param no_default : String

  get "/args-with-defaults" do
    plain_text "doesn't matter"
  end
end

class OptionalRouteParams::Index < TestAction
  get "/complex_posts/:required/?:optional_1/?:optional_2" do
    plain_text "test"
  end
end

class Tests::ActionWithPrefix < TestAction
  route_prefix "/prefix"

  get "/so_custom2" do
    plain_text "doesn't matter"
  end
end

describe Lucky::Action do
  it "has a url helper" do
    Lucky::RouteHelper.temp_config(base_uri: "example.com") do
      Tests::Index.url.should eq "example.com/tests"
      Tests::ActionWithPrefix.url.should eq "example.com/prefix/so_custom2"
    end
  end

  describe ".url_without_query_params" do
    it "returns url without declared non-nil query params" do
      Lucky::RouteHelper.temp_config(base_uri: "example.com") do
        RequiredParams::Index.url_without_query_params.should eq "example.com/required_params"
      end
    end

    it "returns url with (required) path params" do
      Lucky::RouteHelper.temp_config(base_uri: "example.com") do
        Tests::Edit.url_without_query_params(1).should eq "example.com/tests/1/edit"
      end
    end

    it "returns url with optional path params" do
      Lucky::RouteHelper.temp_config(base_uri: "example.com") do
        OptionalRouteParams::Index.url_without_query_params(1).should eq "example.com/complex_posts/1"
        OptionalRouteParams::Index.url_without_query_params(1, 2).should eq "example.com/complex_posts/1/2"
        OptionalRouteParams::Index.url_without_query_params(1, 2, 3).should eq "example.com/complex_posts/1/2/3"
      end
    end
  end

  describe "routing" do
    it "creates URL helpers for the resourceful actions" do
      Tests::Index.path.should eq "/tests"
      Tests::Index.route.should eq Lucky::RouteHelper.new(:get, "/tests")
      Tests::New.path.should eq "/tests/new"
      Tests::New.route.should eq Lucky::RouteHelper.new(:get, "/tests/new")
      Tests::Edit.path("test-id").should eq "/tests/test-id/edit"
      Tests::Edit.with("test-id").should eq Lucky::RouteHelper.new(:get, "/tests/test-id/edit")
      Tests::Show.path("test-id").should eq "/tests/test-id"
      Tests::Show.with("test-id").should eq Lucky::RouteHelper.new(:get, "/tests/test-id")
      Tests::Delete.path("test-id").should eq "/tests/test-id"
      Tests::Delete.with("test-id").should eq Lucky::RouteHelper.new(:delete, "/tests/test-id")
      Tests::Update.path("test-id").should eq "/tests/test-id"
      Tests::Update.with("test-id").should eq Lucky::RouteHelper.new(:put, "/tests/test-id")
      Tests::Create.path.should eq "/tests"
      Tests::Create.route.should eq Lucky::RouteHelper.new(:post, "/tests")
      Tests::ActionWithPrefix.path.should eq "/prefix/so_custom2"
    end

    it "escapes path params" do
      Tests::Edit.path("test/id").should eq "/tests/test%2Fid/edit"
      Tests::Edit.with("test/id").should eq Lucky::RouteHelper.new(:get, "/tests/test%2Fid/edit")
    end

    it "adds routes to the router" do
      assert_route_added? Lucky::Route.new :get, "/tests", Tests::Index
      assert_route_added? Lucky::Route.new :get, "/tests/new", Tests::New
      assert_route_added? Lucky::Route.new :get, "/tests/:test_id/edit", Tests::Edit
      assert_route_added? Lucky::Route.new :get, "/tests/:test_id", Tests::Show
      assert_route_added? Lucky::Route.new :delete, "/tests/:test_id", Tests::Delete
      assert_route_added? Lucky::Route.new :put, "/tests/:test_id", Tests::Update
      assert_route_added? Lucky::Route.new :post, "/tests", Tests::Create
    end

    it "allows setting custom routes" do
      assert_route_not_added? Lucky::Route.new :get, "/custom_routes", CustomRoutes::Index

      assert_route_added? Lucky::Route.new :get, "/so_custom", CustomRoutes::Index
      assert_route_added? Lucky::Route.new :put, "/so_custom", CustomRoutes::Put
      assert_route_added? Lucky::Route.new :post, "/so_custom", CustomRoutes::Post
      assert_route_added? Lucky::Route.new :patch, "/so_custom", CustomRoutes::Patch
      assert_route_added? Lucky::Route.new :trace, "/so_custom", CustomRoutes::Trace
      assert_route_added? Lucky::Route.new :delete, "/so_custom", CustomRoutes::Delete
      assert_route_added? Lucky::Route.new :options, "/so_custom", CustomRoutes::Match
    end

    it "works with optional routing paths" do
      route = OptionalRouteParams::Index.with(required: "1")
      route.should eq Lucky::RouteHelper.new(:get, "/complex_posts/1")
      route.path.should eq "/complex_posts/1"

      route2 = OptionalRouteParams::Index.with(required: "1", optional_1: "2")
      route2.should eq Lucky::RouteHelper.new(:get, "/complex_posts/1/2")
      route2.path.should eq "/complex_posts/1/2"

      route3 = OptionalRouteParams::Index.with(required: "1", optional_1: "2", optional_2: "3")
      route3.should eq Lucky::RouteHelper.new(:get, "/complex_posts/1/2/3")
      route3.path.should eq "/complex_posts/1/2/3"
    end
  end

  describe "rendering" do
    it "renders plain text" do
      response = PlainText::Index.new(build_context, params).call
      response.body.to_s.should eq "plain"
      response.content_type.should eq "text/plain"
    end

    it "infer the correct HTML page to render" do
      response = Tests::Index.new(build_context, params).call
      response.body.to_s.should contain "Rendered from Tests::IndexPage"
      response.content_type.should eq "text/html"
    end
  end

  describe ".query_param_declarations" do
    it "returns an empty array" do
      PlainText::Index.query_param_declarations.size.should eq 0
    end

    it "returns required param declarations" do
      RequiredParams::Index.query_param_declarations.size.should eq 2
      RequiredParams::Index.query_param_declarations.should contain "required_page : Int32"
      RequiredParams::Index.query_param_declarations.should contain "bool_with_false_default : Bool"
    end

    it "returns optional param declarations" do
      OptionalParams::Index.query_param_declarations.size.should eq 6
      OptionalParams::Index.query_param_declarations.should contain "bool_with_false_default : Bool | ::Nil"
    end
  end

  describe "params" do
    it "can get params" do
      action = PlainText::Index.new(build_context(path: "/?q=test"), params)
      action.params.get(:q).should eq "test"
    end

    it "can get manually defined required params" do
      action = RequiredParams::Index.new(build_context(path: "/?required_page=1"), params)
      action.required_page.should eq 1
    end

    it "adds named arguments to the path" do
      RequiredParams::Index.path(required_page: 7).should eq "/required_params?required_page=7"
      RequiredParams::Index.path(required_page: 7, bool_with_false_default: true).should eq "/required_params?required_page=7&bool_with_false_default=true"
    end

    it "adds named arguments to the route" do
      RequiredParams::Index.route(required_page: 7).should eq Lucky::RouteHelper.new(:get, "/required_params?required_page=7")
    end

    it "raises for missing required params" do
      action = RequiredParams::Index.new(build_context(path: ""), params)
      expect_raises(Lucky::MissingParamError) { action.required_page }
    end

    it "can inherit params" do
      InheritedParams::Index.path(inherit_me: "inherited").should eq "/inherited_params?inherit_me=inherited"
    end
  end

  it "can add anchors to routes (and escapes them)" do
    Tests::Index.path(anchor: "#foo").should eq "/tests#%23foo"
    Tests::Index.route(anchor: "#foo").path.should eq "/tests#%23foo"
    Tests::Index.url(anchor: "#foo").ends_with?("/tests#%23foo").should be_true
  end

  describe "params with defaults" do
    it "are put at the end of the arg list so the program compiles" do
      ParamsWithDefaultParamsLast.with(no_default: "Yay!")
    end
  end

  describe "optional params" do
    it "are not required in the route helper" do
      path = OptionalParams::Index.path
      path.should eq("/optional_params")
    end

    it "is initialized to nil" do
      action = OptionalParams::Index.new(build_context(path: ""), params)
      action.page.should eq nil
    end

    it "is fetched if present" do
      action = OptionalParams::Index.new(build_context(path: "/?page=3"), params)
      action.page.should eq 3
    end

    it "can be used within the action" do
      response = OptionalParams::Index.new(build_context(path: "/?page=3"), params).call
      response.body.to_s.should eq "optional param: 3 1 1337"
    end

    it "can specify a default value" do
      action = OptionalParams::Index.new(build_context(path: ""), params)
      action.with_default.should eq "default"
    end

    it "can specify nil as the default value" do
      action = OptionalParams::Index.new(build_context(path: ""), params)
      action.nilable_with_explicit_nil.should eq nil
    end

    it "overrides the default if present" do
      action = OptionalParams::Index.new(build_context(path: "/?with_int_never_nil=42"), params)
      action.with_int_never_nil.should eq 42
    end

    it "is added as optional argument to the path" do
      OptionalParams::Index.path(page: 7).should eq "/optional_params?page=7"
      OptionalParams::Index.path(page: 7, with_default: "/other").should eq "/optional_params?page=7&with_default=%2Fother"
    end

    it "is added to the path if the value matches default and is explicitly given" do
      OptionalParams::Index.path(with_default: "default").should eq "/optional_params?with_default=default"
    end

    it "is not added to the path param has default value but not given" do
      OptionalParams::Index.path.should eq "/optional_params"
    end

    it "is added as optional argument to the route" do
      OptionalParams::Index.route(page: 7).should eq Lucky::RouteHelper.new(:get, "/optional_params?page=7")
      OptionalParams::Index.route(page: 7, with_default: "/other").should eq Lucky::RouteHelper.new(:get, "/optional_params?page=7&with_default=%2Fother")
    end

    it "raises when the optional param cannot be parsed into the desired type" do
      expect_raises Lucky::InvalidParamError do
        OptionalParams::Index.new(build_context(path: "/?page=no_int"), params()).call
      end
    end

    it "raises when we cannot parse the non-optional param into the desired type" do
      expect_raises Lucky::InvalidParamError, "Required param 'with_int_never_nil' with value 'no_int' couldn't be parsed to a 'Int32'" do
        OptionalParams::Index.new(build_context(path: "/?with_int_never_nil=no_int"), params()).call
      end
    end
  end
end

private def assert_route_added?(expected_route)
  Lucky::Router.routes.should contain(expected_route)
end

private def assert_route_not_added?(expected_route)
  Lucky::Router.routes.should_not contain(expected_route)
end
