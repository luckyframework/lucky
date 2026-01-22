require "../spec_helper"

include ContextHelper

private class TestParamAction < TestAction
  get "/test/:param_1/:param_2" do
    plain_text "test"
  end
end

private class TestOptionalParamAction < TestAction
  get "/test_complex_posts/:required/?:optional_1/?:optional_2" do
    plain_text "test"
  end
end

private class TestGlobAction < TestAction
  get "/test_complex_posts_glob/*" do
    plain_text "test"
  end
end

private class TestNamedGlobAction < TestAction
  get "/test_complex_posts_named_glob/*:leftover" do
    plain_text "test"
  end
end

describe "Automatically generated param helpers" do
  it "generates helpers for all route params" do
    action = TestParamAction.new(build_context, {"param_1" => "param_1_value", "param_2" => "param_2_value"})
    action.param_1.should eq "param_1_value"
    action.param_2.should eq "param_2_value"
    typeof(action.param_1).should eq String
    typeof(action.param_2).should eq String
  end

  it "generates helpers for optional route params" do
    action = TestOptionalParamAction.new(build_context, {"required" => "1", "optional_1" => "2"})
    action.required.should eq "1"
    action.optional_1.should eq "2"
    action.optional_2.should eq nil
    typeof(action.optional_1).should eq String?
    typeof(action.optional_2).should eq String?
  end

  it "generates helper for unnamed glob" do
    action = TestGlobAction.new(build_context, {"glob" => "globbed/path"})
    action.glob.should eq "globbed/path"

    action = TestGlobAction.new(build_context, {} of String => String)
    action.glob.should be_nil

    typeof(action.glob).should eq String?
  end

  it "generates helper for named glob" do
    action = TestNamedGlobAction.new(build_context, {"leftover" => "globbed/path"})
    action.leftover.should eq "globbed/path"

    action = TestNamedGlobAction.new(build_context, {} of String => String)
    action.leftover.should be_nil

    typeof(action.leftover).should eq String?
  end
end

describe "Glob route URL building" do
  it "builds URL with unnamed glob param using .with" do
    TestGlobAction.with(glob: "some/path").path.should eq "/test_complex_posts_glob/some/path"
  end

  it "builds URL with named glob param using .with" do
    TestNamedGlobAction.with(leftover: "some/path").path.should eq "/test_complex_posts_named_glob/some/path"
  end

  it "builds URL without glob param" do
    TestGlobAction.with.path.should eq "/test_complex_posts_glob"
    TestNamedGlobAction.with.path.should eq "/test_complex_posts_named_glob"
  end

  it "builds URL with nil glob param" do
    TestGlobAction.with(glob: nil).path.should eq "/test_complex_posts_glob"
    TestNamedGlobAction.with(leftover: nil).path.should eq "/test_complex_posts_named_glob"
  end

  it "URL-encodes special characters in glob segments" do
    TestGlobAction.with(glob: "path with spaces/and more").path.should eq "/test_complex_posts_glob/path+with+spaces/and+more"
  end

  it "normalizes consecutive slashes in glob value" do
    TestGlobAction.with(glob: "a//b").path.should eq "/test_complex_posts_glob/a/b"
  end

  it "strips leading slashes from glob value" do
    TestGlobAction.with(glob: "/leading/slash").path.should eq "/test_complex_posts_glob/leading/slash"
  end

  it "builds URL with glob using .route" do
    TestNamedGlobAction.route(leftover: "some/path").path.should eq "/test_complex_posts_named_glob/some/path"
  end

  it "builds path_without_query_params with glob" do
    TestNamedGlobAction.path_without_query_params(leftover: "some/path").should eq "/test_complex_posts_named_glob/some/path"
  end

  it "builds url_without_query_params with glob" do
    Lucky::RouteHelper.temp_config(base_uri: "example.com") do
      TestNamedGlobAction.url_without_query_params(leftover: "some/path").should eq "example.com/test_complex_posts_named_glob/some/path"
    end
  end

  it "returns correct RouteHelper with glob" do
    route_helper = TestGlobAction.with(glob: "a/b/c")
    route_helper.should eq Lucky::RouteHelper.new(:get, "/test_complex_posts_glob/a/b/c")
  end
end
