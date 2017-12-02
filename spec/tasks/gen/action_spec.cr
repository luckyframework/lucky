require "../../spec_helper"

describe Gen::Action do
  it "generates a basic action" do
    begin
      ARGV.push("Users::Index")
      Gen::Action.new.call

      File.exists?("src/actions/users/index.cr").should be_true
    ensure
      ARGV.pop
      FileUtils.rm_rf "src/actions/users/index.cr"
    end
  end

  it "generates a nested action" do
    begin
      ARGV.push("Users::Announcements::Index")
      Gen::Action.new.call

      File.exists?("src/actions/users/announcements/index.cr").should be_true
    ensure
      ARGV.pop
      FileUtils.rm_rf "src/actions/users/announcements/index.cr"
    end
  end

  it "displays an error if given no arguments" do
    io = IO::Memory.new

    Gen::Action.new.call(io)
    message = "\e[31mAction name is required. Example: lucky gen.action Users::Index\e[0m"

    io.to_s.strip.should eq(message)
  end

  it "displays an error if given only one class" do
    begin
      io = IO::Memory.new
      ARGV.push("Users")

      Gen::Action.new.call(io)
      message = "\e[31mThat's not a valid Action.  Example: lucky gen.action Users::Index\e[0m"

      io.to_s.strip.should eq(message)
    ensure
      ARGV.pop
    end
  end
end
