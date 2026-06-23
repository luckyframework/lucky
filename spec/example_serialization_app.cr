# Example application demonstrating all serialization formats in Lucky
#
# This file shows how to use the new configurable serialization system
# with real-world examples for each supported format.

require "spec_helper"

# Sample data model
private class User
  property id : Int32
  property name : String
  property email : String
  property created_at : Time

  def initialize(@id : Int32, @name : String, @email : String, @created_at : Time = Time.utc)
  end

  def to_json(json : JSON::Builder)
    json.object do
      json.field "id", @id
      json.field "name", @name
      json.field "email", @email
      json.field "created_at", @created_at.to_rfc3339
    end
  end

  def to_yaml(yaml : YAML::Nodes::Builder)
    yaml.mapping do
      yaml.scalar "id"
      yaml.scalar @id.to_s
      yaml.scalar "name"
      yaml.scalar @name
      yaml.scalar "email"
      yaml.scalar @email
      yaml.scalar "created_at"
      yaml.scalar @created_at.to_rfc3339
    end
  end

  def to_csv
    "#{@id},#{@name},#{@email},#{@created_at.to_rfc3339}"
  end
end

# Multi-format serializer using the built-in modules
private class UserSerializer
  include Lucky::Serializable
  include Lucky::Serializable::JSON
  include Lucky::Serializable::YAML
  include Lucky::Serializable::CSV

  def initialize(@user : User)
  end

  def render
    @user
  end

  def context
    build_context
  end

  private def enable_cookies? : Bool
    true
  end
end

# Custom format example - XML using the define_format macro
Lucky::Serializable.define_format(
  name: "XML",
  method: "to_xml",
  content_type: "application/xml",
  mime_type: :xml
)

private class XMLUser
  def initialize(@user : User)
  end

  def to_xml
    <<-XML
    <user>
      <id>#{@user.id}</id>
      <name>#{@user.name}</name>
      <email>#{@user.email}</email>
      <created_at>#{@user.created_at.to_rfc3339}</created_at>
    </user>
    XML
  end
end

private class UserXMLSerializer
  include Lucky::Serializable
  include Lucky::Serializable::XML

  def initialize(@user : User)
  end

  def render
    XMLUser.new(@user)
  end

  def context
    build_context
  end

  private def enable_cookies? : Bool
    true
  end
end

# API Actions demonstrating different approaches
private class UsersController < TestAction
  accepted_formats [:html, :json, :yaml, :csv, :xml], default: :json

  # Content negotiation endpoint
  get "/users" do
    users = [
      User.new(1, "Alice", "alice@example.com"),
      User.new(2, "Bob", "bob@example.com"),
    ]
    respond_with users
  end

  # Explicit format endpoints
  get "/users.json" do
    user = User.new(1, "Alice", "alice@example.com")
    json user
  end

  get "/users.yaml" do
    user = User.new(1, "Alice", "alice@example.com")
    yaml user
  end

  get "/users.csv" do
    users = [
      User.new(1, "Alice", "alice@example.com"),
      User.new(2, "Bob", "bob@example.com"),
    ]
    csv_data = "id,name,email,created_at\n" + users.map(&.to_csv).join("\n")
    csv csv_data
  end

  # Using custom serializers
  get "/users/:id/detailed" do
    user = User.new(id.to_i, "Alice", "alice@example.com")
    serializer = UserSerializer.new(user)

    case request.headers["Accept"]?
    when .try(&.includes?("application/yaml"))
      serializer.to_yaml_response
    when .try(&.includes?("text/csv"))
      serializer.to_csv_response
    when .try(&.includes?("application/xml"))
      xml_serializer = UserXMLSerializer.new(user)
      xml_serializer.to_xml_response
    else
      serializer.to_json_response
    end
  end
end

describe "Example Serialization App" do
  it "demonstrates JSON serialization" do
    user = User.new(1, "Alice", "alice@example.com")
    user.to_json.should contain("Alice")
    user.to_json.should contain("alice@example.com")
  end

  it "demonstrates multi-format serializer" do
    user = User.new(1, "Alice", "alice@example.com")
    serializer = UserSerializer.new(user)

    # JSON response
    json_response = serializer.to_json_response
    json_response.content_type.should eq("application/json")
    json_response.status.should eq(200)

    # YAML response
    yaml_response = serializer.to_yaml_response
    yaml_response.content_type.should eq("application/yaml")

    # CSV response
    csv_response = serializer.to_csv_response
    csv_response.content_type.should eq("text/csv")
  end

  it "demonstrates custom XML format" do
    user = User.new(1, "Alice", "alice@example.com")
    xml_serializer = UserXMLSerializer.new(user)

    xml_response = xml_serializer.to_xml_response
    xml_response.content_type.should eq("application/xml")
    xml_response.body.to_s.should contain("<name>Alice</name>")
  end

  it "shows how easy it is to add new formats" do
    # Adding TOML support would be as simple as:
    # Lucky::Serializable.define_format(
    #   name: "TOML",
    #   method: "to_toml",
    #   content_type: "application/toml",
    #   mime_type: :toml
    # )

    # Then include Lucky::Serializable::TOML in your serializers
    # and use serializer.to_toml_response

    true.should be_true # Placeholder assertion
  end
end
