require "../../spec_helper"

include CleanupHelper

describe Gen::Model do
  it "generates a model" do
    with_cleanup do
      io = IO::Memory.new
      model_name = "ContactInfo"
      ARGV.push(model_name)

      Gen::Model.new.call(io)

      File.read("./src/models/contact_info.cr").
        should contain("class ContactInfo < BaseModel")
      io.to_s.should contain("contact_info.cr")
      io.to_s.should contain("./src/models")
      File.read("./src/forms/contact_info_form.cr").
        should contain("class ContactInfoForm < ContactInfo::BaseForm")
      io.to_s.should contain("contact_info_form.cr")
      io.to_s.should contain("./src/forms")
      File.read("./src/queries/contact_info_query.cr").
        should contain("class ContactInfoQuery < ContactInfo::BaseQuery")
      io.to_s.should contain("contact_info_query.cr")
      io.to_s.should contain("./src/queries")
    end
  end

  it "displays an error if given no arguments" do
    io = IO::Memory.new

    Gen::Model.new.call(io)

    io.to_s.should contain("Model name is required.")
  end
end
