require "../../../spec_helper"

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
end
