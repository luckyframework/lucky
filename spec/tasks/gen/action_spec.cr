require "../../spec_helper"

describe Gen::Action do
  it "generates a basic action" do
    begin
      valid_action_name = "Users::Index"
      ARGV.push(valid_action_name)

      Gen::Action.new.call

      File.read("./src/actions/users/index.cr").
        should contain(valid_action_name)
    ensure
      cleanup
    end
  end

  it "generates a nested action" do
    begin
      valid_nested_action_name = "Users::Announcements::Index"
      ARGV.push(valid_nested_action_name)

      Gen::Action.new.call

      File.read("src/actions/users/announcements/index.cr").
        should contain(valid_nested_action_name)
    ensure
      cleanup
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
      invalid_action_name = "Users"
      ARGV.push(invalid_action_name)

      Gen::Action.new.call(io)
      message = "\e[31mThat's not a valid Action.  Example: lucky gen.action Users::Index\e[0m"

      io.to_s.strip.should eq(message)
    ensure
      ARGV.clear
    end
  end
end

private def cleanup
  ARGV.clear
  FileUtils.rm_rf("./src/actions")
end
