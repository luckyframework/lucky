require "../../spec_helper"

include CleanupHelper
include GeneratorHelper

describe Gen::Page do
  it "generates a page" do
    with_cleanup do
      io = IO::Memory.new
      valid_page_name = "Users::IndexPage"
      ARGV.push(valid_page_name)

      Gen::Page.new.call(io)

      should_create_files_with_contents io,
        "./src/pages/users/index_page.cr": valid_page_name
    end
  end

  it "generates a root page" do
    with_cleanup do
      io = IO::Memory.new
      valid_page_name = "::IndexPage"
      ARGV.push(valid_page_name)

      Gen::Page.new.call(io)

      should_create_files_with_contents io,
        "./src/pages/index_page.cr": valid_page_name
    end
  end

  it "displays an error if given no arguments" do
    io = IO::Memory.new

    Gen::Page.new.call(io)

    io.to_s.should contain("Page name is required.")
  end

  it "displays an error if given only one class" do
    with_cleanup do
      io = IO::Memory.new
      invalid_page_name = "Users"
      ARGV.push(invalid_page_name)

      Gen::Page.new.call(io)

      io.to_s.should contain("That's not a valid Page.")
    end
  end

  it "displays an error if missing ending 'Page'" do
    with_cleanup do
      io = IO::Memory.new
      invalid_page_name = "Users::Index"
      ARGV.push(invalid_page_name)

      Gen::Page.new.call(io)

      io.to_s.should contain("That's not a valid Page.")
    end
  end
end
