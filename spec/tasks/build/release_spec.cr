require "../../spec_helper"

include CleanupHelper

describe Build::Release do
  it "creates an executable if a `src/server.cr` file exists" do
    with_cleanup do
      Dir.mkdir_p("./src")
      File.write "./src/server.cr", "puts 1"

      Build::Release.new(IO::Memory.new).call

      File.exists?("./server").should be_true
    end
  end

  it "does not create executable if the build fails" do
    with_cleanup do
      Dir.mkdir_p("./src")
      File.write "./src/server.cr", %({{ raise "this build will fail" }})

      Build::Release.new(IO::Memory.new, error_io: IO::Memory.new).call

      File.exists?("./server").should be_false
    end
  end
end
