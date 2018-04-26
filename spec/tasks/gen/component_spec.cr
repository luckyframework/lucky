require "../../spec_helper"

include CleanupHelper

describe Gen::Component do
  it "generates a component" do
    with_cleanup do
      io = IO::Memory.new
      valid_name = "Users::Row"
      ARGV.push(valid_name)

      Gen::Component.new.call(io)

      File.read("./src/components/users/row.cr")
          .should contain(valid_name)
      io.to_s.should contain(valid_name)
      io.to_s.should contain("/src/components/users/row.cr")
    end
  end

  it "displays an error if given no arguments" do
    io = IO::Memory.new

    Gen::Component.new.call(io)

    io.to_s.should contain("Component name is required.")
  end

  it "displays an error if given only one class" do
    with_cleanup do
      io = IO::Memory.new
      invalid_name = "Users"
      ARGV.push(invalid_name)

      Gen::Component.new.call(io)

      io.to_s.should contain("Components must be namespaced")
    end
  end
end
