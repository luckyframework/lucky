require "../../spec_helper"

include CleanupHelper
include GeneratorHelper

describe Gen::Action do
  it "generates actions, model, form and query" do
    with_cleanup do
      io = generate Gen::Resource::Browser, "User", "name:String"

      should_create_files_with_contents io,
        "./src/actions/users/index.cr": "class Users::Index < BrowserAction",
        "./src/actions/users/show.cr": "class Users::Show < BrowserAction",
        "./src/actions/users/new.cr": "class Users::New < BrowserAction",
        "./src/actions/users/create.cr": "class Users::Create < BrowserAction",
        "./src/actions/users/edit.cr": "class Users::Edit < BrowserAction",
        "./src/actions/users/update.cr": "class Users::Update < BrowserAction",
        "./src/actions/users/delete.cr": "class Users::Delete < BrowserAction"
      should_create_files_with_contents io,
        "./src/pages/users/index_page.cr": "class Users::IndexPage < MainLayout",
        "./src/pages/users/show_page.cr": "class Users::ShowPage < MainLayout",
        "./src/pages/users/new_page.cr": "class Users::NewPage < MainLayout",
        "./src/pages/users/edit_page.cr": "class Users::EditPage < MainLayout"
      should_create_files_with_contents io,
        "./src/models/user.cr": "class User < BaseModel",
        "./src/queries/user_query.cr": "class UserQuery < User::BaseQuery",
        "./src/forms/user_form.cr": "class UserForm < User::BaseForm"
      should_generate_migration named: "create_users.cr"
    end
  end

  it "displays an error if given no arguments" do
    with_cleanup do
      io = generate Gen::Resource::Browser, ""

      io.to_s.should contain("Resource name is required.")
    end
  end

  it "displays an error if given a pluralized resource" do
    with_cleanup do
      io = generate Gen::Resource::Browser, "Users"

      io.to_s.should contain("Resource must be singular")
    end
  end

  it "raises if column options are missing" do
    with_cleanup do
      io = generate Gen::Resource::Browser, "User"

      io.to_s.should contain("Must provide valid columns for the resource")
    end
  end

  it "raises if column options are not formatted right" do
    with_cleanup do
      io = generate Gen::Resource::Browser, "User", "name", "String"

      io.to_s.should contain("Must provide valid columns for the resource")
    end
  end

  it "does not accept namespaced resources yet" do
    with_cleanup do
      io = generate Gen::Resource::Browser, "Admin::User"

      io.to_s.should contain("Namespaced resources are not supported")
    end
  end
end

private def generate(generator : Class, *options)
  options.each { |option| ARGV.push(option) }
  IO::Memory.new.tap do |io|
    generator.new.call(io)
  end
end
