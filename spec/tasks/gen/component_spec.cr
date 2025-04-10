require "../../spec_helper"

include CleanupHelper
include GeneratorHelper

describe Gen::Component do
  it "generates a component" do
    with_cleanup do
      valid_name = "Users::Row"

      task = Gen::Component.new
      task.output = IO::Memory.new
      task.print_help_or_call(args: [valid_name])

      should_create_files_with_contents task.output,
        "./src/components/users/row.cr": valid_name
    end
  end

  it "generates a root component" do
    with_cleanup do
      valid_name = "Root"

      task = Gen::Component.new
      task.output = IO::Memory.new
      task.print_help_or_call(args: [valid_name])

      should_create_files_with_contents task.output,
        "./src/components/root.cr": valid_name
    end
  end

  it "displays an error if given no arguments" do
    task = Gen::Component.new
    task.output = IO::Memory.new
    task.print_help_or_call(args: [] of String)

    task.output.to_s.should contain("Component name is required.")
  end

  it "displays an error if not given a class" do
    with_cleanup do
      task = Gen::Component.new
      task.output = IO::Memory.new
      task.print_help_or_call(args: ["mycomponent"])

      task.output.to_s.should contain("Component name should be camel case")
    end
  end
end
