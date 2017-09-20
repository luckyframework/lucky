require "../../spec_helper"

class BasePage
  include LuckyWeb::Page

  needs name : String
end

class AdminPage < BasePage
  needs admin_name : String
end

class PageOne < BasePage
  needs title : String
  needs second : String

  render do
  end
end

class PageTwo < BasePage
  needs title : String

  render do
  end
end

class PageThree < AdminPage
  needs title : String

  render do
  end
end

describe "Assigns within multiple pages with the same name" do
  it "should only appear once in the initializer" do
    PageOne.new title: "foo", name: "Paul", second: "second"
    PageTwo.new title: "foo", name: "Paul"
    PageThree.new name: "Paul", admin_name: "Pablo", title: "Admin"
  end
end
