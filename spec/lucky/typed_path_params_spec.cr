require "../spec_helper"

include ContextHelper

private struct ColorCode
  getter value : String

  def initialize(@value : String)
  end
end

module Lucky::ParamParser
  def self.parse(param : String, klass : ColorCode.class) : ColorCode?
    param.matches?(/\A[0-9a-fA-F]{6}\z/) ? ColorCode.new(param) : nil
  end
end

@[Lucky::PathParam(code: ColorCode)]
private class TypedCustomParamAction < TestAction
  get "/typed_path_params/custom/:code" do
    plain_text "test"
  end
end

@[Lucky::PathParam(id: UUID)]
private class TypedUUIDParamAction < TestAction
  get "/typed_path_params/uuid/:id" do
    plain_text "test"
  end
end

@[Lucky::PathParam(org_id: Int64, id: UUID)]
private class TypedMixedParamAction < TestAction
  get "/typed_path_params/orgs/:org_id/users/:id/:slug" do
    plain_text "test"
  end
end

@[Lucky::PathParam(page: Int32)]
private class TypedOptionalParamAction < TestAction
  get "/typed_path_params/optional/:required/?:page" do
    plain_text "test"
  end
end

describe "Typed path params" do
  it "types a required path param based on the annotation" do
    uuid = UUID.new("11111111-2222-3333-4444-555555555555")
    action = TypedUUIDParamAction.new(build_context, {"id" => uuid.to_s})

    action.id.should eq uuid
    typeof(action.id).should eq UUID
  end

  it "raises Lucky::InvalidParamError when a typed accessor is read with an unparsable value" do
    action = TypedUUIDParamAction.new(build_context, {"id" => "not-a-uuid"})

    expect_raises(Lucky::InvalidParamError, "'id'") do
      action.id
    end
  end

  it "types multiple params of different types and leaves undeclared params as String" do
    uuid = UUID.new("11111111-2222-3333-4444-555555555555")
    action = TypedMixedParamAction.new(build_context, {
      "org_id" => "42",
      "id"     => uuid.to_s,
      "slug"   => "hello",
    })

    action.org_id.should eq 42_i64
    action.id.should eq uuid
    action.slug.should eq "hello"

    typeof(action.org_id).should eq Int64
    typeof(action.id).should eq UUID
    typeof(action.slug).should eq String
  end

  it "types an optional path param, parsing when present" do
    action = TypedOptionalParamAction.new(build_context, {"required" => "x", "page" => "5"})

    action.page.should eq 5
    typeof(action.page).should eq Int32?
  end

  it "returns nil for an absent optional typed path param" do
    action = TypedOptionalParamAction.new(build_context, {"required" => "x"})

    action.page.should be_nil
  end
end

describe "Typed path params matching guard" do
  it "reports valid_path_params? true for values that parse" do
    uuid = UUID.new("11111111-2222-3333-4444-555555555555")
    TypedUUIDParamAction.valid_path_params?({"id" => uuid.to_s}).should be_true
  end

  it "reports valid_path_params? false for values that can't parse" do
    TypedUUIDParamAction.valid_path_params?({"id" => "not-a-uuid"}).should be_false
  end

  it "reports valid_path_params? true for an absent optional typed param" do
    TypedOptionalParamAction.valid_path_params?({"required" => "x"}).should be_true
  end

  it "supports a custom type via a user-defined ParamParser.parse overload" do
    action = TypedCustomParamAction.new(build_context, {"code" => "ff0000"})

    action.code.should eq ColorCode.new("ff0000")
    typeof(action.code).should eq ColorCode
  end

  it "reports valid_path_params? false for a custom type the overload rejects" do
    TypedCustomParamAction.valid_path_params?({"code" => "nope"}).should be_false
    TypedCustomParamAction.valid_path_params?({"code" => "ff0000"}).should be_true
  end

  it "reports valid_path_params? false for a present but unparsable optional typed param" do
    TypedOptionalParamAction.valid_path_params?({"required" => "x", "page" => "abc"}).should be_false
  end

  it "defaults valid_path_params? to true for actions without the annotation" do
    TypedUUIDParamAction.as(Lucky::Action.class)
    Lucky::Action.valid_path_params?({"anything" => "goes"}).should be_true
  end
end

describe "Typed path params in the RouteHandler" do
  it "dispatches the action when a typed segment parses" do
    uuid = UUID.new("11111111-2222-3333-4444-555555555555")
    called_next = false
    context = build_context(path: "/typed_path_params/uuid/#{uuid}")
    handler = Lucky::RouteHandler.new
    handler.next = ->(_ctx : HTTP::Server::Context) { called_next = true; nil }

    handler.call(context)

    called_next.should be_false
  end

  it "falls through (404) when a typed segment can't be parsed" do
    called_next = false
    context = build_context(path: "/typed_path_params/uuid/not-a-uuid")
    handler = Lucky::RouteHandler.new
    handler.next = ->(_ctx : HTTP::Server::Context) { called_next = true; nil }

    handler.call(context)

    called_next.should be_true
  end
end
