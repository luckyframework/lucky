require "../spec_helper"

include ContextHelper

private abstract struct BaseSerializerStruct
  include Lucky::Serializable
end

private struct FoodSerializer < BaseSerializerStruct
  def initialize(@name : String)
  end

  def render
    {name: @name}
  end
end

private abstract class BaseSerializerClass
  include Lucky::Serializable
end

private class DrinksSerializer < BaseSerializerClass
  def initialize(@name : String)
  end

  def render
    {name: @name}
  end
end

private class JsonSerializer < BaseSerializerClass
  include Lucky::Serializable::JSON

  def initialize(@data : Hash(String, String))
  end

  def render
    @data
  end

  def context
    build_context
  end

  private def enable_cookies? : Bool
    true
  end
end

private class YamlSerializer < BaseSerializerClass
  include Lucky::Serializable::YAML

  def initialize(@data : Hash(String, String))
  end

  def render
    @data
  end

  def context
    build_context
  end

  private def enable_cookies? : Bool
    true
  end
end

private class MockDataWithAllFormats
  def initialize(@data : Hash(String, String))
  end

  def to_json
    @data.to_json
  end

  def to_yaml
    @data.to_yaml
  end

  def to_msgpack
    @data.to_json # Mock msgpack as JSON for testing
  end

  def to_csv
    # Simple CSV mock
    keys = @data.keys.join(",")
    values = @data.values.join(",")
    "#{keys}\n#{values}"
  end
end

private class MultiFormatSerializer < BaseSerializerClass
  include Lucky::Serializable::JSON
  include Lucky::Serializable::YAML
  include Lucky::Serializable::MsgPack
  include Lucky::Serializable::CSV

  def initialize(@data : Hash(String, String))
  end

  def render
    MockDataWithAllFormats.new(@data)
  end

  def context
    build_context
  end

  private def enable_cookies? : Bool
    true
  end
end

describe Lucky::Serializable do
  context "with structs" do
    describe "#to_json" do
      it "calls to_json on the render data" do
        FoodSerializer.new("tacos").to_json.should eq(%({"name":"tacos"}))
      end
    end
  end

  context "with classes" do
    describe "#to_json" do
      it "calls to_json on the render data" do
        DrinksSerializer.new("water").to_json.should eq(%({"name":"water"}))
      end
    end
  end

  context "with format modules" do
    describe "JSON module" do
      it "creates JSON responses with correct content type" do
        serializer = MultiFormatSerializer.new({"message" => "hello"})
        response = serializer.to_json_response

        response.should be_a(Lucky::TextResponse)
        response.content_type.should eq("application/json")
        response.body.to_s.should eq(%({"message":"hello"}))
        response.status.should eq(200)
      end

      it "creates JSON responses with custom status" do
        serializer = MultiFormatSerializer.new({"error" => "not found"})
        response = serializer.to_json_response(404)

        response.status.should eq(404)
      end

      it "creates JSON responses with HTTP::Status" do
        serializer = MultiFormatSerializer.new({"created" => "true"})
        response = serializer.to_json_response(HTTP::Status::CREATED)

        response.status.should eq(201)
      end
    end

    describe "YAML module" do
      it "creates YAML responses with correct content type" do
        serializer = MultiFormatSerializer.new({"message" => "hello"})
        response = serializer.to_yaml_response

        response.should be_a(Lucky::TextResponse)
        response.content_type.should eq("application/yaml")
        response.body.to_s.should contain("message: hello")
        response.status.should eq(200)
      end

      it "creates YAML responses with custom status" do
        serializer = MultiFormatSerializer.new({"error" => "not found"})
        response = serializer.to_yaml_response(404)

        response.status.should eq(404)
      end

      it "creates YAML responses with HTTP::Status" do
        serializer = MultiFormatSerializer.new({"created" => "true"})
        response = serializer.to_yaml_response(HTTP::Status::CREATED)

        response.status.should eq(201)
      end
    end

    describe "MsgPack module" do
      it "creates MsgPack responses with correct content type" do
        serializer = MultiFormatSerializer.new({"message" => "hello"})
        response = serializer.to_msgpack_response

        response.should be_a(Lucky::TextResponse)
        response.content_type.should eq("application/msgpack")
        response.status.should eq(200)
      end

      it "creates MsgPack responses with custom status" do
        serializer = MultiFormatSerializer.new({"error" => "not found"})
        response = serializer.to_msgpack_response(404)

        response.status.should eq(404)
      end

      it "creates MsgPack responses with HTTP::Status" do
        serializer = MultiFormatSerializer.new({"created" => "true"})
        response = serializer.to_msgpack_response(HTTP::Status::CREATED)

        response.status.should eq(201)
      end
    end

    describe "CSV module" do
      it "creates CSV responses with correct content type" do
        serializer = MultiFormatSerializer.new({"message" => "hello"})
        response = serializer.to_csv_response

        response.should be_a(Lucky::TextResponse)
        response.content_type.should eq("text/csv")
        response.status.should eq(200)
      end

      it "creates CSV responses with custom status" do
        serializer = MultiFormatSerializer.new({"error" => "not found"})
        response = serializer.to_csv_response(404)

        response.status.should eq(404)
      end

      it "creates CSV responses with HTTP::Status" do
        serializer = MultiFormatSerializer.new({"created" => "true"})
        response = serializer.to_csv_response(HTTP::Status::CREATED)

        response.status.should eq(201)
      end
    end
  end
end
