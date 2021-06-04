require "../spec_helper"

include ContextHelper
include MultipartHelper

class BasicParams
  include Lucky::ParamSerializable
  skip_param_key

  property string : String
  property int16 : Int16
  property int32 : Int32
  property int64 : Int64
  property bool : Bool
  property float64 : Float64
  property uuid : UUID
  property blank : String?
end

class UserWithKeyParams
  include Lucky::ParamSerializable
  param_key :user

  property name : String
  property age : Int32
  property fellowship : String?
end

class ComplexParams
  include Lucky::ParamSerializable

  property tags : Array(String)
  property numbers : Array(Int32)
  property default : Bool = true
  @[Lucky::ParamField(param_key: :override)]
  property version : Float64
  @[Lucky::ParamField(ignore: true)]
  property internal : Int32 = 4
end

class CrashingParams
  include Lucky::ParamSerializable
  skip_param_key

  property required_but_missing : String
  @[Lucky::ParamField(param_key: :key)]
  property wrong : Bool
end

# {
#   "query":{
#     "bool":{
#       "must":[
#          {"terms":{"brand":["micromax","samsung"]}}
#       ] ,
#       "should":[
#          { "range": { "price": { "gte": 6000, "lte": 10000 } } },
#          { "range": { "price": { "gte": 16000, "lte": 30000 } } }
#       ]
#     }
#   }
# }

# class SearchParams
#   include Lucky::ParamSerializable

#   property q : String
#   property page : Int32
#   property per : Int32 = 50
#   property sort : Array(String)
#   @[Lucky::ParamField(param_key: :filter)]
#   property active : Bool = false
#   @[Lucky::ParamField(param_key: :filter)]
#   property city : String

# end

describe Lucky::ParamSerializable do
  describe "param_key" do
    it "checks the key on all params" do
      request = build_request
      request.query = "user:name=Gandalf&user:age=11000&fellowship=bracelet"

      params = Lucky::Params.new(request)
      user_params = UserWithKeyParams.from_params(params)

      user_params.param_key.should eq "user"
      user_params.name.should eq("Gandalf")
      user_params.age.should eq(11000)
      user_params.fellowship.should be_nil
    end
  end

  describe "handling errors" do
    it "raises an exception when the required value is missing" do
      request = build_request
      request.query = "wrong=true"
      params = Lucky::Params.new(request)

      expect_raises(Lucky::MissingParamError) do
        CrashingParams.from_params(params)
      end
    end
  end

  describe "query params" do
    it "parses the basic param types" do
      request = build_request
      request.query = "string=Test&int16=1&int32=123&int64=12341234&bool=true&float64=3.14&uuid=d65869ee-f08f-47ff-b15d-568dc23c2eb7&fellowship=bracelet"

      run_basic_assertions(request)
    end

    it "parses more complex param types" do
      request = build_request
      request.query = "complex_params:tags[]=one&complex_params:tags[]=two&complex_params:numbers[]=1&complex_params:numbers[]=2&override:version=0.1&complex_params:internal=2"

      run_complext_assertions(request)
    end
  end

  describe "form params" do
    it "parses the basic param types" do
      request = build_request body: "string=Test&int16=1&int32=123&int64=12341234&bool=true&float64=3.14&uuid=d65869ee-f08f-47ff-b15d-568dc23c2eb7&fellowship=bracelet",
        content_type: "application/x-www-form-urlencoded"

      run_basic_assertions(request)
    end

    it "parses more complex param types" do
      request = build_request body: "complex_params:tags[]=one&complex_params:tags[]=two&complex_params:numbers[]=1&complex_params:numbers[]=2&override:version=0.1",
        content_type: "application/x-www-form-urlencoded"

      run_complext_assertions(request)
    end
  end

  describe "json params" do
    it "parses the basic param types" do
      json = {string: "Test", int16: 1, int32: 123, int64: 12341234, bool: true, float64: 3.14, uuid: "d65869ee-f08f-47ff-b15d-568dc23c2eb7", fellowship: "bracelet"}
      request = build_request body: json.to_json, content_type: "application/json"

      run_basic_assertions(request)
    end

    it "parses more complex param types" do
      json = {complex_params: {tags: ["one", "two"], numbers: [1, 2]}, override: {version: 0.1}}
      request = build_request body: json.to_json, content_type: "application/json"

      run_complext_assertions(request)
    end
  end

  describe "multipart params" do
    it "parses the basic param types" do
      request = build_multipart_request form_parts: {
        "string" => "Test", "int16" => "1", "int32" => "123", "int64" => "12341234", "bool" => "true", "float64" => "3.14",
        "uuid" => "d65869ee-f08f-47ff-b15d-568dc23c2eb7", "fellowship" => "bracelet",
      }

      run_basic_assertions(request)
    end

    it "parses more complex param types" do
      request = build_multipart_request form_parts: {
        "complex_params:tags" => ["one", "two"], "complex_params:numbers" => ["1", "2"],
        "override:version" => "0.1",
      }

      run_complext_assertions(request)
    end
  end
end

private def run_basic_assertions(req : HTTP::Request)
  params = Lucky::Params.new(req)
  user_params = BasicParams.from_params(params)

  user_params.string.should eq("Test")
  user_params.int16.should eq(1_i16)
  user_params.int32.should eq(123_i32)
  user_params.int64.should eq(12341234_i64)
  user_params.bool.should eq(true)
  user_params.float64.should eq(3.14)
  user_params.uuid.should eq(UUID.new("d65869ee-f08f-47ff-b15d-568dc23c2eb7"))
  user_params.blank.should be_nil
  user_params.responds_to?(:fellowship).should be_false
end

private def run_complext_assertions(req : HTTP::Request)
  params = Lucky::Params.new(req)
  complex_params = ComplexParams.from_params(params)

  complex_params.tags.should eq(["one", "two"])
  complex_params.numbers.should eq([1, 2])
  complex_params.default.should eq(true)
  complex_params.version.should eq(0.1)
  complex_params.internal.should eq(4)
end
