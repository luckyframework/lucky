require "../../spec_helper"

include CleanupHelper

describe Gen::Model do
  it "generates a model" do
    with_cleanup do
      io = IO::Memory.new
      model_name = "User"
      ARGV.push(model_name)

      Gen::Model.new.call(io)

      File.read("./src/models/user.cr").
        should contain("class User < BaseModel")
      File.read("./src/forms/user_form.cr").
        should contain("class UserForm < User::BaseForm")
      File.read("./src/queries/user_query.cr").
        should contain("class UserQuery < User::BaseQuery")
    end
  end

  it "displays an error if given no arguments" do
    io = IO::Memory.new

    Gen::Model.new.call(io)

    io.to_s.should contain("Model name is required.")
  end
end
