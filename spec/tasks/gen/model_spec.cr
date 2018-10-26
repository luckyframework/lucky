require "../../spec_helper"

include CleanupHelper
include GeneratorHelper

describe Gen::Model do
  it "generates a model" do
    with_cleanup do
      Gen::Migration.silence_output do
        io = IO::Memory.new
        model_name = "ContactInfo"
        ARGV.push(model_name)

        Gen::Model.new.call(io)

        should_generate_migration named: "create_contact_infos.cr"
        should_create_files_with_contents io,
          "./src/models/contact_info.cr": "table :contact_infos"
        should_create_files_with_contents io,
          "./src/models/contact_info.cr": "class ContactInfo < BaseModel",
          "./src/forms/contact_info_form.cr": "class ContactInfoForm < ContactInfo::BaseForm",
          "./src/queries/contact_info_query.cr": "class ContactInfoQuery < ContactInfo::BaseQuery"
      end
    end
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
end
