require "../../spec_helper"

include CleanupHelper
include GeneratorHelper

describe Gen::Component do
  it "generates a component" do
    with_cleanup do
      io = IO::Memory.new
      valid_name = "Users::Row"
      ARGV.push(valid_name)

      Gen::Component.new.call(io)

      should_create_files_with_contents io,
        "./src/components/users/row.cr": valid_name
    end
  end

  it "generates a root component" do
    with_cleanup do
      io = IO::Memory.new
      valid_name = "Root"
      ARGV.push(valid_name)

      Gen::Component.new.call(io)

      should_create_files_with_contents io,
        "./src/components/root.cr": valid_name
    end
  end

  it "displays an error if given no arguments" do
    io = IO::Memory.new

    Gen::Component.new.call(io)

    io.to_s.should contain("Component name is required.")
  end

  it "displays an error if not given a class" do
    with_cleanup do
      io = IO::Memory.new
      invalid_component = "mycomponent"
      ARGV.push(invalid_component)

      Gen::Component.new.call(io)

      io.to_s.should contain("Component name should be camel case")
    end
  end
end
