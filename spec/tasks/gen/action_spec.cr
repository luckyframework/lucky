require "../../spec_helper"

include CleanupHelper

describe Gen::Action do
  it "generates a basic browser action" do
    with_cleanup do
      valid_action_name = "Users::Index"
      io = generate valid_action_name, Gen::Action::Browser

      filename = "./src/actions/users/index.cr"
      should_have_generated "#{valid_action_name} < BrowserAction", inside: filename

      io.to_s.should contain(valid_action_name)
      io.to_s.should contain("/src/actions/users")
    end
  end

  it "generates a basic api action" do
    with_cleanup do
      valid_action_name = "Users::Index"
      io = generate valid_action_name, Gen::Action::Api

      filename = "./src/actions/users/index.cr"
      should_have_generated "#{valid_action_name} < ApiAction", inside: filename

      io.to_s.should contain(valid_action_name)
      io.to_s.should contain("/src/actions/users")
    end
  end

  it "generates nested browser and api actions" do
    with_cleanup do
      valid_nested_action_name = "Users::Announcements::Index"
      io = generate valid_nested_action_name, Gen::Action::Browser

      filename = "src/actions/users/announcements/index.cr"
      should_have_generated "#{valid_nested_action_name} < BrowserAction", inside: filename

      io.to_s.should contain(valid_nested_action_name)
      io.to_s.should contain("/src/actions/users/announcements")
    end

    with_cleanup do
      valid_nested_action_name = "Users::Announcements::Index"
      io = generate valid_nested_action_name, Gen::Action::Api

      filename = "src/actions/users/announcements/index.cr"
      should_have_generated "#{valid_nested_action_name} < ApiAction", inside: filename

      io.to_s.should contain(valid_nested_action_name)
      io.to_s.should contain("/src/actions/users/announcements")
    end

    it "snake cases filenames of a camel case action" do
      with_cleanup do
        valid_camel_case_action_name = "Users::HostedEvents"
        io = generate valid_camel_case_action_name, Gen::Action::Browser

        should_have_generated valid_camel_case_action_name, inside: "src/actions/users/hosted_events.cr"
        io.to_s.should contain(valid_camel_case_action_name)
        io.to_s.should contain("/src/actions/users")
      end
    end
  end

  it "displays an error if given no arguments" do
    io = generate nil, Gen::Action::Browser

    io.to_s.should contain("Action name is required.")
  end

  it "displays an error if given only one class" do
    with_cleanup do
      io = generate "Users", Gen::Action::Browser

      io.to_s.should contain("That's not a valid Action.")
    end
  end
end

private def generate(name, generator : Class)
  ARGV.push(name) if name
  io = IO::Memory.new
  generator.new.call(io)
  io
end

private def should_have_generated(text, inside)
  File.read(inside).should contain(text)
end
