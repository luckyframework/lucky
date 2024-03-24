require "../../spec_helper"

describe Gen::SecretKey do
  it "outputs a new secret key base" do
    task = Gen::SecretKey.new
    task.output = IO::Memory.new
    task.print_help_or_call(args: [] of String)

    (task.output.to_s.size >= 32).should be_true
  end

  it "outputs a larger size when configured" do
    task = Gen::SecretKey.new
    task.output = IO::Memory.new
    task.print_help_or_call(args: ["-n 64"])

    (task.output.to_s.size >= 64).should be_true
  end
end
