require "../../spec_helper"

include CleanupHelper
include GeneratorHelper

describe Gen::Model do
  it "generates a model" do
    with_cleanup do
      Gen::Migration.silence_output do
        io = IO::Memory.new
        model_name = "Customer"
        ARGV.push(model_name)

        Gen::Model.new.call(io)

        should_create_files_with_contents io,
          "./src/models/customer.cr": "table"
        should_create_files_with_contents io,
          "./src/operations/save_customer.cr": "# permit_columns column_1, column_2"
        should_create_files_with_contents io,
          "./src/models/customer.cr": "class Customer < BaseModel",
          "./src/operations/save_customer.cr": "class SaveCustomer < Customer::SaveOperation",
          "./src/queries/customer_query.cr": "class CustomerQuery < Customer::BaseQuery"
        should_generate_migration named: "create_customers.cr"
      end
    end
  end

  it "generates a model with columns" do
    with_cleanup do
      Gen::Migration.silence_output do
        io = IO::Memory.new
        model_name = "ContactInfo"
        ARGV.push(model_name, "name:String", "contacted_at:Time")

        Gen::Model.new.call(io)

        should_create_files_with_contents io,
          "./src/models/contact_info.cr": "table"
        should_create_files_with_contents io,
          "./src/models/contact_info.cr": "column name : String",
          "./src/operations/save_contact_info.cr": "# permit_columns name, contacted_at"
        should_create_files_with_contents io,
          "./src/models/contact_info.cr": "class ContactInfo < BaseModel",
          "./src/operations/save_contact_info.cr": "class SaveContactInfo < ContactInfo::SaveOperation",
          "./src/queries/contact_info_query.cr": "class ContactInfoQuery < ContactInfo::BaseQuery"
        should_generate_migration named: "create_contact_infos.cr",
          with: "add contacted_at : Time"
      end
    end
  end

  it "displays an error when given a more complex type" do
    io = IO::Memory.new
    ARGV.push("Alphabet", "a:JSON::Any")

    Gen::Model.new.call(io)

    io.to_s.should contain("Other complex types can be added manually")
  end

  it "displays an error if given no arguments" do
    io = IO::Memory.new

    Gen::Model.new.call(io)

    io.to_s.should contain("Model name is required.")
  end

  it "displays an error if argument is not camelcase" do
    with_cleanup do
      io = IO::Memory.new
      ARGV.push("invalid_name")

      Gen::Model.new.call(io)

      io.to_s.should contain("Model name should be camel case")
    end
  end

  it "displays an error if the name contains weird characters" do
    with_cleanup do
      io = IO::Memory.new
      ARGV.push(":-)sillyame")
      Gen::Model.new.call(io)
      io.to_s.should contain("Model name should only contain letters")
    end
  end

  it "displays an error if the model has already been generated" do
    with_cleanup do
      ARGV.push("User")

      Gen::Migration.silence_output do
        io = IO::Memory.new
        Gen::Model.new.call(io)
      end

      io = IO::Memory.new
      Gen::Model.new.call(io)
      io.to_s.should contain("'User' model already exists at ./src/models/user.cr")
    end
  end
end
