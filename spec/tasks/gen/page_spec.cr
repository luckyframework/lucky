require "../../spec_helper"

include CleanupHelper

describe Gen::Page do
  it "generates a page" do
    with_cleanup do
      io = IO::Memory.new
      valid_page_name = "Users::IndexPage"
      ARGV.push(valid_page_name)

      Gen::Page.new.call(io)

      File.read("./src/pages/users/index_page.cr")
          .should contain(valid_page_name)
      io.to_s.should contain(valid_page_name)
      io.to_s.should contain("/src/pages/users/index_page.cr")
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
