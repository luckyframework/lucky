require "../../spec_helper"

include CleanupHelper
include GeneratorHelper

describe Gen::Action do
  it "generates a basic browser action" do
    with_cleanup do
      valid_action_name = "Users::Index"
      io = generate Gen::Action::Browser, args: [valid_action_name]

      filename = "./src/actions/users/index.cr"
      should_have_generated "#{valid_action_name} < BrowserAction", inside: filename

      io.to_s.should contain(valid_action_name)
      io.to_s.should contain("/src/actions/users")
    end
  end

  describe "with_page" do
    it "generates the action and a page for Browser action" do
      with_cleanup do
        valid_action_name = "Users::Index"
        io = generate Gen::Action::Browser, args: [valid_action_name, "--with-page"]

        action_filename = "./src/actions/users/index.cr"
        page_filename = "./src/pages/users/index_page.cr"
        should_have_generated "#{valid_action_name} < BrowserAction", inside: action_filename
        should_have_generated "#{valid_action_name}Page < MainLayout", inside: page_filename

        io.to_s.should contain(valid_action_name)
        io.to_s.should contain("/src/actions/users")
        io.to_s.should contain("/src/pages/users")
      end
    end

    it "does not generate a page for Api action" do
      with_cleanup do
        valid_action_name = "Users::Index"
        io = generate Gen::Action::Api, args: [valid_action_name, "--with-page"]

        filename = "./src/actions/api/users/index.cr"
        should_have_generated "#{valid_action_name} < ApiAction", inside: filename

        io.to_s.should contain(valid_action_name)
        io.to_s.should contain("/src/actions/api/users")
        io.to_s.should contain("No page generated for ApiActions")
      end
    end
  end

  it "generates a basic api action" do
    with_cleanup do
      valid_action_name = "Users::Index"
      io = generate Gen::Action::Api, args: [valid_action_name]

      filename = "./src/actions/api/users/index.cr"
      should_have_generated "#{valid_action_name} < ApiAction", inside: filename

      io.to_s.should contain(valid_action_name)
      io.to_s.should contain("/src/actions/api/users")
    end
  end

  it "generates nested browser and api actions" do
    with_cleanup do
      valid_nested_action_name = "Users::Announcements::Index"
      io = generate Gen::Action::Browser, args: [valid_nested_action_name]

      filename = "src/actions/users/announcements/index.cr"
      should_have_generated "#{valid_nested_action_name} < BrowserAction", inside: filename
      should_have_generated %(get "/users/announcements"), inside: filename

      io.to_s.should contain(valid_nested_action_name)
      io.to_s.should contain("/src/actions/users/announcements")
    end

    with_cleanup do
      valid_nested_action_name = "Users::Announcements::Index"
      io = generate Gen::Action::Api, args: [valid_nested_action_name]

      filename = "src/actions/api/users/announcements/index.cr"
      should_have_generated "#{valid_nested_action_name} < ApiAction", inside: filename

      io.to_s.should contain(valid_nested_action_name)
      io.to_s.should contain("/src/actions/api/users/announcements")
    end
  end

  it "fails if called with non-resourceful action name" do
    io = generate Gen::Action::Browser, args: ["Users::HostedEvents"]

    io.to_s.should contain "Could not infer route for Users::HostedEvents"
  end

  it "raises an error if given no arguments" do
    expect_raises(Exception, /action_name is required/) do
      generate Gen::Action::Browser
    end
  end

  it "displays an error if given only one class" do
    with_cleanup do
      io = generate Gen::Action::Browser, args: ["Users"]

      io.to_s.should contain("That's not a valid Action.")
    end
  end

  it "generates the correct template" do
    template = Lucky::ActionTemplate.new(
      name: "User::Index",
      action: "index",
      inherit_from: "BrowserAction",
      route: %(get "/users")
    )
    folder = template.template_folder
    LuckyTemplate.snapshot(folder).has_key?("src/actions/user/index.cr").should eq(true)
  end
end
