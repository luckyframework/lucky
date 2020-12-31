require "../../spec_helper"

include CleanupHelper
include GeneratorHelper

describe Gen::Resource::Browser do
  it "generates actions, model, operation and query" do
    with_cleanup do
      Gen::Migration.silence_output do
        io = generate Gen::Resource::Browser, "User", "name:String", "notes:String?", "signed_up:Time"

        should_create_files_with_contents io,
          "./src/actions/users/index.cr": "class Users::Index < BrowserAction",
          "./src/actions/users/show.cr": "class Users::Show < BrowserAction",
          "./src/actions/users/new.cr": "class Users::New < BrowserAction",
          "./src/actions/users/create.cr": "class Users::Create < BrowserAction",
          "./src/actions/users/edit.cr": "class Users::Edit < BrowserAction",
          "./src/actions/users/update.cr": "class Users::Update < BrowserAction",
          "./src/actions/users/delete.cr": "class Users::Delete < BrowserAction"
        should_create_files_with_contents io,
          "./src/actions/users/index.cr": %(get "/users"),
          "./src/actions/users/show.cr": %(get "/users/:user_id"),
          "./src/actions/users/new.cr": %(get "/users/new"),
          "./src/actions/users/create.cr": %(post "/users"),
          "./src/actions/users/edit.cr": %(get "/users/:user_id/edit"),
          "./src/actions/users/update.cr": %(put "/users/:user_id"),
          "./src/actions/users/delete.cr": %(delete "/users/:user_id")
        should_create_files_with_contents io,
          "./src/actions/users/show.cr": "html ShowPage, user: UserQuery.find(user_id)",
          "./src/actions/users/edit.cr": "user = UserQuery.find(user_id)",
          "./src/actions/users/update.cr": "user = UserQuery.find(user_id)",
          "./src/actions/users/delete.cr": "UserQuery.find(user_id).delete"
        should_create_files_with_contents io,
          "./src/pages/users/index_page.cr": "class Users::IndexPage < MainLayout",
          "./src/pages/users/show_page.cr": "class Users::ShowPage < MainLayout",
          "./src/pages/users/new_page.cr": "class Users::NewPage < MainLayout",
          "./src/pages/users/edit_page.cr": "class Users::EditPage < MainLayout",
          "./src/components/users/form_fields.cr": "class Users::FormFields < BaseComponent"
        should_create_files_with_contents io,
          "./src/models/user.cr": "class User < BaseModel",
          "./src/queries/user_query.cr": "class UserQuery < User::BaseQuery",
          "./src/operations/save_user.cr": "class SaveUser < User::SaveOperation"
        should_create_files_with_contents io,
          "./src/operations/save_user.cr": "permit_columns name, notes, signed_up"
        should_generate_migration named: "create_users.cr"
        should_generate_migration named: "create_users.cr", with: "add name : String"
        should_generate_migration named: "create_users.cr", with: "add signed_up : Time"
        should_generate_migration named: "create_users.cr", with: "add notes : String?"
        io.to_s.should contain "at: #{"/users".colorize.green}"
      end
    end
  end

  describe "error messages for unsupported column types" do
    it "contains each unsupported type passed in the arguments" do
      with_cleanup do
        bad_int_column = "int_column:integer"
        bad_text_column = "text_column:text"
        good_string_column = "good_column:String"
        good_optional_string_column = "good_optional_column:String?"
        io = IO::Memory.new
        ARGV.push("ModelName", bad_int_column, bad_text_column, good_string_column, good_optional_string_column)

        Gen::Model.new.call(io)

        io.to_s.should contain("Unable to generate model ModelName")
        io.to_s.should contain("the following columns are using types not supported by the generator")
        io.to_s.should contain(bad_int_column)
        io.to_s.should contain(bad_text_column)
        io.to_s.should_not contain(good_string_column)
        io.to_s.should_not contain(good_optional_string_column)
      end
    end

    it "displays an error when given a more complex type" do
      io = IO::Memory.new
      ARGV.push("Alphabet", "a:BigDecimal")

      Gen::Model.new.call(io)

      io.to_s.should contain("For more complex types that can be added to your migrations manually")
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

      io.to_s.should contain("Resource requires at least one column definition")
      io.to_s.should contain("User")
    end
  end

  it "raises if column options are not formatted right" do
    with_cleanup do
      io = generate Gen::Resource::Browser, "User", "name", "String"

      io.to_s.should contain("Unable to generate model User")
      io.to_s.should contain("the following columns are using types not supported by the generator")
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
