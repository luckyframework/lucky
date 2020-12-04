require "../../spec_helper"

include CleanupHelper
include GeneratorHelper

private def run_with_args(args : Array(String))
  generator = Gen::Task.new
  generator.output = IO::Memory.new
  generator.print_help_or_call args
  generator.output
end

describe Gen::Task do
  it "generates a task" do
    with_cleanup do
      output = run_with_args ["search.reindex"]
      output.to_s.should contain("Generated ./tasks/search/reindex.cr")
      should_create_files_with_contents output,
        "./tasks/search/reindex.cr": "Search::Reindex"
    end
  end

  it "displays an error if no name is provided" do
    expect_raises Exception, /task_name is required/ do
      run_with_args [] of String
    end
  end

  it "displays an error if the name is formatted as a class" do
    run_with_args(["GenericTask"]).to_s.should contain("needs to be formatted with dot notation")
    run_with_args(["genericTask"]).to_s.should contain("needs to be formatted with dot notation")
  end

  it "uses a default summary if none is provided" do
    with_cleanup do
      output = run_with_args ["generic_task"]
      should_create_files_with_contents output,
        "./tasks/generic_task.cr": "summary \"generic task\""
    end
  end

  it "uses the provided summary" do
    with_cleanup do
      output = run_with_args ["generic_task", "--task-summary", "this is the summary"]
      should_create_files_with_contents output,
        "./tasks/generic_task.cr": "summary \"this is the summary\""
    end
  end
end
