require "../spec_helper"

include ContextHelper
include MultipartHelper

class BasicParams
  include Lucky::ParamSerializable
  skip_param_key

  param string : String
  param int16 : Int16
  param int32 : Int32
  param int64 : Int64
  param bool : Bool
  param float64 : Float64
  param uuid : UUID
  param blank : String?
end

class UserWithKeyParams
  include Lucky::ParamSerializable
  param_key :user

  param name : String
  param age : Int32
  param fellowship : String?
end

class ComplexParams
  include Lucky::ParamSerializable

  param tags : Array(String)
  param numbers : Array(Int32)
  param default : Bool = true
  param version : Float64, param_key: :override
  property internal : Int32 = 4
end

class CrashingParams
  include Lucky::ParamSerializable
  skip_param_key

  param required_but_missing : String
  param wrong : Bool, param_key: :key
end

class ParamsWithFile
  include Lucky::ParamSerializable
  param_key :data

  param avatar : Lucky::UploadedFile
  param docs : Array(Lucky::UploadedFile)
end

class LocationParams
  include Lucky::ParamSerializable
  param_key :location

  param lat : Float64
  param lng : Float64
end

class AddressParams
  include Lucky::ParamSerializable
  param_key :address

  param street : String
  param location : LocationParams
end

class ActorParams
  include Lucky::ParamSerializable
  param_key :actor

  param name : String = "George"
  param age : Int32?
end

describe Lucky::ParamSerializable do
  describe "param_key" do
    it "checks the key on all params" do
      request = build_request
      request.query = "user:name=Gandalf&user:age=11000&fellowship=bracelet"

      params = Lucky::Params.new(request)
      user_params = UserWithKeyParams.from_params(params)

      user_params.name.value.should eq("Gandalf")
      user_params.age.value.should eq(11000)
      user_params.fellowship.should be_nil
    end
  end

  # You may have a nilable type with a non-nil value (say, in the Database).
  # We need to make the distinction between you passing a nil value through params
  # to "null-out" the value VS the value being nil because no param value was passed
  # thus not nulling out the data.
  describe "handling nilable types with values" do
    it "returns nil when no value was set" do
      request = build_request
      request.query = "actor:name=Jim"

      params = Lucky::Params.new(request)
      actor_params = ActorParams.from_params(params)

      actor_params.age.should be_nil
    end

    it "returns a permitted param with a nil value when passed a blank param" do
      request = build_request
      request.query = "actor:name=Jim&actor:age="

      params = Lucky::Params.new(request)
      actor_params = ActorParams.from_params(params)

      actor_params.age.class.name.should contain("Lucky::PermittedParam")
      actor_params.age.not_nil!.value.should be_nil
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

    it "raises an exception when the required value is the wrong type" do
      request = build_request
      request.query = "actor:name=Jim&actor:age=Nabors"

      params = Lucky::Params.new(request)

      expect_raises(Lucky::InvalidParamError) do
        ActorParams.from_params(params)
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

      run_complex_assertions(request)
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

      run_complex_assertions(request)
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

      run_complex_assertions(request)
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

      run_complex_assertions(request)
    end

    describe "with files" do
      it "parses with an UploadedFile" do
        request = build_multipart_request file_parts: {
          "data:avatar" => "file_contents",
          "data:docs"   => ["file1", "file2"],
        }

        params = Lucky::Params.new(request)
        file_params = ParamsWithFile.from_params(params)

        file_params.avatar.value.should be_a(Lucky::UploadedFile)
        file_params.docs.value.size.should eq(2)
        File.read(file_params.avatar.value.path).should eq "file_contents"
        File.read(file_params.docs.value.last.path).should eq "file2"
      end
    end
  end

  describe "manually assigning values" do
    it "allows you to manually assign values" do
      actor_params = ActorParams.new(name: "Mario", age: 32)

      actor_params.name.value.should eq("Mario")
      actor_params.age.not_nil!.value.should eq(32)
    end
  end

  context "with associated objects" do
    it "serializes the associated object" do
      request = build_request
      request.query = "address:street=123+street&address:location:lat=1.1&address:location:lng=-1.2"

      params = Lucky::Params.new(request)
      address_params = AddressParams.from_params(params)

      address_params.street.value.should eq("123 street")

      location = address_params.location.value
      location.should be_a(LocationParams)
      location.lat.value.should eq(1.1)
      location.lng.value.should eq(-1.2)
    end
  end
end

private def run_basic_assertions(req : HTTP::Request)
  params = Lucky::Params.new(req)
  user_params = BasicParams.from_params(params)

  user_params.string.value.should eq("Test")
  user_params.int16.value.should eq(1_i16)
  user_params.int32.value.should eq(123_i32)
  user_params.int64.value.should eq(12341234_i64)
  user_params.bool.value.should eq(true)
  user_params.float64.value.should eq(3.14)
  user_params.uuid.value.should eq(UUID.new("d65869ee-f08f-47ff-b15d-568dc23c2eb7"))
  user_params.blank.should be_nil
  user_params.responds_to?(:fellowship).should be_false
end

private def run_complex_assertions(req : HTTP::Request)
  params = Lucky::Params.new(req)
  complex_params = ComplexParams.from_params(params)

  complex_params.tags.value.should eq(["one", "two"])
  complex_params.numbers.value.should eq([1, 2])
  complex_params.default.value.should eq(true)
  complex_params.version.value.should eq(0.1)
  complex_params.internal.should eq(4)
end
