require "../../spec_helper"

include CleanupHelper
include GeneratorHelper

describe Gen::Page do
  it "generates a page" do
    with_cleanup do
      valid_page_name = "Users::IndexPage"
      io = generate Gen::Page, args: [valid_page_name]

      should_create_files_with_contents io,
        "./src/pages/users/index_page.cr": valid_page_name
    end
  end

  it "generates a root page" do
    with_cleanup do
      valid_page_name = "::IndexPage"
      io = generate Gen::Page, args: [valid_page_name]

      should_create_files_with_contents io,
        "./src/pages/index_page.cr": valid_page_name
    end
  end

  it "displays an error if given no arguments" do
    expect_raises(Exception, /page_class is required/) do
      generate Gen::Page
    end
  end

  it "displays an error if given only one class" do
    with_cleanup do
      invalid_page_name = "Users"
      io = generate Gen::Page, args: [invalid_page_name]

      io.to_s.should contain("That's not a valid Page.")
    end
  end

  it "displays an error if missing ending 'Page'" do
    with_cleanup do
      invalid_page_name = "Users::Index"
      io = generate Gen::Page, args: [invalid_page_name]

      io.to_s.should contain("That's not a valid Page.")
    end
  end
end
