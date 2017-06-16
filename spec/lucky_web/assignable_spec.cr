require "../../spec_helper"

class BasePage
  include LuckyWeb::Page

  macro inherited
    assign name : String
  end
end

class PageOne < BasePage
  assign title : String
  assign second : String

  render do
  end
end

class PageTwo < BasePage
  assign title : String

  render do
  end
end

describe "Assigns within multiple pages with the same name" do
  it "should only appear once in the initializer" do
    PageOne.new title: "foo", name: "Paul", second: "second"
    PageTwo.new title: "foo", name: "Paul"
  end
end
