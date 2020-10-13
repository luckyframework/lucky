require "../spec_helper"

include ContextHelper

private class User < Avram::Model
  table do
    column name : String
  end
end

describe "Errors" do
  describe Avram::InvalidOperationError do
    it "is renderable and includes error details" do
      operation = User::SaveOperation.new
      operation.valid?.should be_false

      error = Avram::InvalidOperationError.new(operation)

      error.should be_a(Lucky::RenderableError)
      error.invalid_attribute_name.should eq("name")
      error.renderable_status.should eq(400)
      error.renderable_message.should contain("Invalid params")
      error.renderable_details.should eq("name is required")
    end
  end

  describe Lucky::InvalidParamError do
    it "is renderable" do
      error = Lucky::InvalidParamError.new(
        param_name: "page",
        param_value: "select%201+1",
        param_type: "Int32")
      error.should be_a(Lucky::RenderableError)
      error.renderable_message.should contain("couldn't be parsed")
      error.renderable_status.should eq 422
    end
  end

  describe Lucky::NotAcceptableError do
    it "is renderable" do
      error = Lucky::NotAcceptableError.new(
        request: build_request,
        format: :any,
        action_name: "Things::Index",
        accepted_formats: [:any])
      error.should be_a(Lucky::RenderableError)
      error.renderable_message.should contain("Accept header")
      error.renderable_status.should eq 406
    end
  end

  describe Lucky::UnknownAcceptHeaderError do
    it "is renderable" do
      error = Lucky::UnknownAcceptHeaderError.new(request: build_request)
      error.should be_a(Lucky::RenderableError)
      error.renderable_message.should contain("Unrecognized Accept header")
      error.renderable_status.should eq 406
    end
  end

  describe Lucky::ParamParsingError do
    it "is renderable" do
      error = Lucky::ParamParsingError.new(request: build_request)
      error.should be_a(Lucky::RenderableError)
      error.renderable_message.should contain("There was a problem parsing the JSON")
      error.renderable_status.should eq 400
    end
  end

  describe Lucky::InvalidParamError do
    it "is renderable" do
      error = Lucky::InvalidParamError.new(
        param_name: "age",
        param_value: "not an int",
        param_type: "Int32"
      )
      error.should be_a(Lucky::RenderableError)
      error.renderable_message.should contain("Required param 'age'")
      error.renderable_status.should eq 422
    end
  end

  describe Lucky::MissingParamError do
    it "is renderable" do
      error = Lucky::MissingParamError.new(param_name: "age")
      error.should be_a(Lucky::RenderableError)
      error.renderable_message.should contain("Missing parameter: 'age'")
      error.renderable_status.should eq 400
    end
  end

  describe Lucky::MissingNestedParamError do
    it "is renderable" do
      error = Lucky::MissingNestedParamError.new(nested_key: "user")
      error.should be_a(Lucky::RenderableError)
      error.renderable_message.should contain("Missing param key: 'user'")
      error.renderable_status.should eq 400
    end
  end
end
