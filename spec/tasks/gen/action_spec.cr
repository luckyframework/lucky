require "../../spec_helper"

describe Gen::Action do
  it "generates a basic action" do
    with_cleanup do
      valid_action_name = "Users::Index"
      ARGV.push(valid_action_name)

      Gen::Action.new.call

      File.read("./src/actions/users/index.cr").
        should contain(valid_action_name)
    end
  end

  it "generates a nested action" do
    with_cleanup do
      valid_nested_action_name = "Users::Announcements::Index"
      ARGV.push(valid_nested_action_name)

      Gen::Action.new.call

      File.read("src/actions/users/announcements/index.cr").
        should contain(valid_nested_action_name)
    end
  end

  it "displays an error if given no arguments" do
    io = IO::Memory.new

    Gen::Action.new.call(io)
    message = "\e[31mAction name is required. Example: lucky gen.action Users::Index\e[0m"

    io.to_s.strip.should eq(message)
  end

  it "displays an error if given only one class" do
    with_cleanup do
      io = IO::Memory.new
      invalid_action_name = "Users"
      ARGV.push(invalid_action_name)

      Gen::Action.new.call(io)
      message = "\e[31mThat's not a valid Action.  Example: lucky gen.action Users::Index\e[0m"

      io.to_s.strip.should eq(message)
    end
  end
end

private def cleanup
  ARGV.clear
  FileUtils.rm_rf("./src/actions")
end

private def with_cleanup
  begin
    yield
  ensure
    cleanup
  end
end
