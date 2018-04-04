require "../../spec_helper"

include CleanupHelper

describe Gen::Action do
  it "generates a basic browser action" do
    with_cleanup do
      io = IO::Memory.new
      valid_action_name = "Users::Index"
      ARGV.push(valid_action_name)

      Gen::Action::Browser.new.call(io)

      index_action = File.read("./src/actions/users/index.cr")
      index_action.should contain(valid_action_name)
      index_action.should contain("< BrowserAction")

      io.to_s.should contain(valid_action_name)
      io.to_s.should contain("/src/actions/users")
    end
  end

  it "generates a basic api action" do
    with_cleanup do
      io = IO::Memory.new
      valid_action_name = "Users::Index"
      ARGV.push(valid_action_name)

      Gen::Action::Api.new.call(io)

      index_action = File.read("./src/actions/users/index.cr")
      index_action.should contain(valid_action_name)
      index_action.should contain("< ApiAction")

      io.to_s.should contain(valid_action_name)
      io.to_s.should contain("/src/actions/users")
    end
  end

  it "generates a nested api action" do
    with_cleanup do
      io = IO::Memory.new
      valid_nested_action_name = "Users::Announcements::Index"
      ARGV.push(valid_nested_action_name)

      Gen::Action::Api.new.call(io)

      index_action = File.read("src/actions/users/announcements/index.cr")
      index_action.should contain(valid_nested_action_name)
      index_action.should contain("< ApiAction")

      io.to_s.should contain(valid_nested_action_name)
      io.to_s.should contain("/src/actions/users/announcements")
    end

    it "snake cases filenames of a camel case action" do
      with_cleanup do
        io = IO::Memory.new
        valid_camel_case_action_name = "Users::HostedEvents"
        ARGV.push(valid_camel_case_action_name)

        Gen::Action::Browser.new.call(io)

        File.read("src/actions/users/hosted_events.cr")
            .should contain(valid_camel_case_action_name)
        io.to_s.should contain(valid_camel_case_action_name)
        io.to_s.should contain("/src/actions/users")
      end
    end
  end

  it "displays an error if given no arguments" do
    io = IO::Memory.new

    Gen::Action::Browser.new.call(io)

    io.to_s.should contain("Action name is required.")
  end

  it "displays an error if given only one class" do
    with_cleanup do
      io = IO::Memory.new
      invalid_action_name = "Users"
      ARGV.push(invalid_action_name)

      Gen::Action::Browser.new.call(io)

      io.to_s.should contain("That's not a valid Action.")
    end
  end
end
