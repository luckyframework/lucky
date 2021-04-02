require "../../spec_helper"

include CleanupHelper

describe Build::Release do
  it "creates an executable if a `src/start_server.cr` file exists" do
    with_cleanup do
      Dir.mkdir_p("./src")
      Dir.mkdir_p("./bin")
      File.write "./src/start_server.cr", "puts 1"

      task = Build::Release.new
      task.output = IO::Memory.new
      task.call
      task.output.to_s.should contain("Build succeeded")

      File.exists?("./bin/start_server").should be_true
    end
  end

  it "does not create executable if the build fails" do
    with_cleanup do
      Dir.mkdir_p("./src")
      Dir.mkdir_p("./bin")
      File.write "./src/start_server.cr", %({{ raise "this build will fail" }})

      task = Build::Release.new
      task.output = IO::Memory.new
      task.error_io = IO::Memory.new
      task.call
      task.error_io.to_s.should contain("this build will fail")

      File.exists?("./bin/start_server").should be_false
    end
  end
end
