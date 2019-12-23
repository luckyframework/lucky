require "../spec_helper"

include ContextHelper

class BasePage
  include Lucky::HTMLPage

  needs name : String
end

class AdminPage < BasePage
  needs admin_name : String
end

class PageOne < BasePage
  needs title : String
  needs second : String

  def render
  end
end

class PageTwo < BasePage
  needs title : String

  def render
  end
end

class PageThree < AdminPage
  needs title : String

  def render
  end
end

class PageWithQuestionMark
  include Lucky::HTMLPage
  needs signed_in? : Bool

  def render
    text @signed_in.to_s
  end
end

class PageWithDefaultsFirst
  include Lucky::HTMLPage
  needs extra_css : String?
  needs status : String = "special"
  needs title : String

  def render
    text "#{@status} #{@title}"
  end
end

describe "Assigns within multiple pages with the same name" do
  it "should only appear once in the initializer" do
    PageOne.new build_context, title: "foo", name: "Paul", second: "second"
    PageTwo.new build_context, title: "foo", name: "Paul"
    PageThree.new build_context, name: "Paul", admin_name: "Pablo", title: "Admin"
    PageWithQuestionMark.new(build_context, signed_in?: true).perform_render.to_s.should contain("true")
    PageWithDefaultsFirst.new(build_context, title: "foo").perform_render.to_s.should contain("special foo")
  end
end
