require "../../spec_helper"

describe Gen::SecretKey do
  it "outputs a new secret key base" do
    io = IO::Memory.new

    Gen::SecretKey.new.call(io)

    (io.to_s.size >= 32).should be_true
  end
end
