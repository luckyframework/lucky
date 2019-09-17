require "../spec_helper"

private class User < Avram::Model
  table do
    column name : String
  end
end

describe Avram::InvalidOperationError do
  it "responds with a custom HTTP code" do
    operation = User::SaveOperation.new
    operation.valid?.should be_false

    error = Avram::InvalidOperationError.new(operation)

    error.should be_a(Lucky::RenderableError)
    error.renderable_status.should eq 400
    error.renderable_message.should contain("Invalid params")
    error.renderable_details.should eq("name is required")
  end
end
