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
  get "/tests" do
    html
  end
end

class Tests::New < TestAction
  get "/tests/new" do
    plain_text "test"
  end
end

class Tests::Edit < TestAction
  get "/tests/:test_id/edit" do
    plain_text "test"
  end
end

class Tests::Show < TestAction
  get "/tests/:test_id" do
    plain_text "test"
  end
end

class Tests::Delete < TestAction
  delete "/tests/:test_id" do
    plain_text "test"
  end
end

class Tests::Update < TestAction
  put "/tests/:test_id" do
    plain_text "test"
  end
end

class Tests::Create < TestAction
  post "/tests" do
    plain_text "test"
  end
end

class PlainText::Index < TestAction
  get "/plain_text" do
    plain_text "plain"
  end
end

class RequiredParams::Index < TestAction
  param required_page : Int32
  # This is to test that the default value of 'false' is not treated as 'nil'
  param bool_with_false_default : Bool = false

  get "/required_params" do
    plain_text "required param: #{required_page} #{bool_with_false_default}"
  end
end

abstract class BaseActionWithParams < TestAction
  param inherit_me : String
end

class InheritedParams::Index < BaseActionWithParams
  get "/inherited_params" do
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
  param nilable_array_with_default : Array(String)? = [] of String
  param with_array_default : Array(Int32) = [26, 37, 44]

  get "/optional_params" do
    plain_text "optional param: #{page} #{with_int_default} #{with_int_never_nil}"
  end
end

class ParamsWithDefaultParamsLast < TestAction
  param has_default : String = "default"
  param has_nil_default : String?
  param no_default : String

  get "/args_with_defaults" do
    plain_text "doesn't matter"
  end
end

class OptionalRouteParams::Index < TestAction
  get "/complex_posts/:required/?:optional_1/?:optional_2" do
    opt = params.get?(:optional_1)
    plain_text "test #{required} #{optional_1} #{optional_2} #{opt}"
  end
end

class Tests::ActionWithPrefix < TestAction
  route_prefix "/prefix"

  get "/so_custom2" do
    plain_text "doesn't matter"
  end
end

class Tests::HtmlActionWithCustomContentType < TestAction
  get "/tests/new_action_with_custom_html_content_type" do
    html(Tests::IndexPage)
  end

  def html_content_type
    "text/html; charset=utf-8"
  end
end

class Tests::JsonActionWithCustomContentType < TestAction
  param override_content_type : String?
  get "/tests/new_action_with_custom_json_content_type" do
    if ct = override_content_type.presence
      raw_json("{}", content_type: ct)
    else
      raw_json("{}")
    end
  end

  def json_content_type
    "application/json; charset=utf-8"
  end
end

class Tests::XmlActionWithCustomContentType < TestAction
  get "/tests/new_action_with_custom_xml_content_type" do
    xml("<code></code>")
  end

  def xml_content_type
    "special/xml; charset=utf-8"
  end
end

class Tests::PlainActionWithCustomContentType < TestAction
  get "/tests/new_action_with_custom_plain_content_type" do
    plain_text("nothing special")
  end

  def plain_content_type
    "very/plain; charset=utf-8"
  end
end

private class SimplleTestComponent < Lucky::BaseComponent
  def render
    text "hi"
  end
end

class Tests::ComponentActionWithCustomContentType < TestAction
  get "/tests/new_action_with_custom_component_content_type" do
    component SimplleTestComponent
  end

  def html_content_type
    "text/html; charset=utf-8"
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

  describe ".path_without_query_params" do
    it "returns path without declared non-nil query params" do
      Lucky::RouteHelper.temp_config(base_uri: "example.com") do
        RequiredParams::Index.path_without_query_params.should eq "/required_params"
      end
    end

    it "returns path with (required) path params" do
      Lucky::RouteHelper.temp_config(base_uri: "example.com") do
        Tests::Edit.path_without_query_params(1).should eq "/tests/1/edit"
      end
    end

    it "returns path with optional path params" do
      Lucky::RouteHelper.temp_config(base_uri: "example.com") do
        OptionalRouteParams::Index.path_without_query_params(1).should eq "/complex_posts/1"
        OptionalRouteParams::Index.path_without_query_params(1, 2).should eq "/complex_posts/1/2"
        OptionalRouteParams::Index.path_without_query_params(1, 2, 3).should eq "/complex_posts/1/2/3"
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
      assert_route_added?(:get, "/tests", Tests::Index)
      assert_route_added?(:get, "/tests/new", Tests::New)
      assert_route_added?(:get, "/tests/:test_id/edit", Tests::Edit)
      assert_route_added?(:get, "/tests/:test_id", Tests::Show)
      assert_route_added?(:delete, "/tests/:test_id", Tests::Delete)
      assert_route_added?(:put, "/tests/:test_id", Tests::Update)
      assert_route_added?(:post, "/tests", Tests::Create)
    end

    it "allows setting custom routes" do
      assert_route_not_added?(:get, "/custom_routes")

      assert_route_added?(:get, "/so_custom", CustomRoutes::Index)
      assert_route_added?(:put, "/so_custom", CustomRoutes::Put)
      assert_route_added?(:post, "/so_custom", CustomRoutes::Post)
      assert_route_added?(:patch, "/so_custom", CustomRoutes::Patch)
      assert_route_added?(:trace, "/so_custom", CustomRoutes::Trace)
      assert_route_added?(:delete, "/so_custom", CustomRoutes::Delete)
      assert_route_added?(:options, "/so_custom", CustomRoutes::Match)
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

    it "uses a custom content_type for this html action" do
      response = Tests::HtmlActionWithCustomContentType.new(build_context, params).call
      response.content_type.should eq "text/html; charset=utf-8"
    end

    it "uses a custom content_type for this component action" do
      response = Tests::ComponentActionWithCustomContentType.new(build_context, params).call
      response.content_type.should eq "text/html; charset=utf-8"
    end

    it "uses a custom content_type for this json action" do
      response = Tests::JsonActionWithCustomContentType.new(build_context, params).call
      response.content_type.should eq "application/json; charset=utf-8"

      response = Tests::JsonActionWithCustomContentType.new(build_context(path: "/tests/new_action_with_custom_json_content_type?override_content_type=cats/dogs"), params).call
      response.content_type.should eq "cats/dogs"
    end

    it "uses a custom content_type for this xml action" do
      response = Tests::XmlActionWithCustomContentType.new(build_context, params).call
      response.content_type.should eq "special/xml; charset=utf-8"
    end

    it "uses a custom content_type for this plain action" do
      response = Tests::PlainActionWithCustomContentType.new(build_context, params).call
      response.content_type.should eq "very/plain; charset=utf-8"
    end

    it "renders with optional path params" do
      response = OptionalRouteParams::Index.new(build_context("/complex_posts/1/2/3"), {"required" => "1", "optional_1" => "2", "optional_2" => "3"}).call
      response.body.to_s.should eq("test 1 2 3 2")
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
      OptionalParams::Index.query_param_declarations.size.should eq 8
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

    it "allows nilable arrays with defaults" do
      action = OptionalParams::Index.new(build_context(path: "/?page=3"), params)
      action.nilable_array_with_default.should eq([] of String)
    end

    it "sets a value to a nilable array" do
      action = OptionalParams::Index.new(build_context(path: "/?nilable_array_with_default[]=1&nilable_array_with_default[]=2"), params)
      action.nilable_array_with_default.should eq(["1", "2"])
    end

    it "allows required arrays with defaults" do
      action = OptionalParams::Index.new(build_context(path: "/?with_array_default=2222222"), params)
      action.with_array_default.should eq([26, 37, 44])
    end
  end
end
