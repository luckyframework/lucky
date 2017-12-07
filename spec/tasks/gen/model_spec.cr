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
      io.to_s.should contain("user.cr")
      io.to_s.should contain("./src/models")
      File.read("./src/forms/user_form.cr").
        should contain("class UserForm < User::BaseForm")
      io.to_s.should contain("user_form.cr")
      io.to_s.should contain("./src/forms")
      File.read("./src/queries/user_query.cr").
        should contain("class UserQuery < User::BaseQuery")
      io.to_s.should contain("user_query.cr")
      io.to_s.should contain("./src/queries")
    end
  end

  it "displays an error if given no arguments" do
    io = IO::Memory.new

    Gen::Model.new.call(io)

    io.to_s.should contain("Model name is required.")
  end
end
