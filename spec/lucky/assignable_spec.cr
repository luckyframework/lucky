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
  needs signed_in : Bool

  def render
    text signed_in?.to_s
  end
end

class PageWithDefaultsFirst
  include Lucky::HTMLPage
  needs required : String
  needs nothing : Bool = false
  needs extra_css : String?
  needs extra_html : String? = nil
  needs optional_metaclass : String.class | Nil
  needs status : String = "special"
  needs title : String

  def render
    text "#{@status} #{@title}"
  end
end

class PageWithMetaclass
  include Lucky::HTMLPage
  needs string_class : String.class
  needs access_me_with_a_getter : String = "called from an auto-generated getter"

  def render
    text access_me_with_a_getter
  end
end

class OverrideGetterPage
  include Lucky::HTMLPage
  needs name : String = "Oops! Not set"

  def render
    text name
  end

  def name
    "Joe"
  end
end

class NonPageClass
  include Lucky::Assignable

  needs param : String
end

class InheritedNonPageClass < NonPageClass
  needs other_param : String
end

describe "Assigns within multiple pages with the same name" do
  it "should only appear once in the initializer" do
    PageOne.new build_context, title: "foo", name: "Paul", second: "second"
    PageTwo.new build_context, title: "foo", name: "Paul"
    PageThree.new build_context, name: "Paul", admin_name: "Pablo", title: "Admin"
    PageWithQuestionMark.new(build_context, signed_in: true).perform_render.to_s.should contain("true")
    PageWithDefaultsFirst.new(build_context, required: "thing", title: "foo").perform_render.to_s.should contain("special foo")
    PageWithMetaclass.new(build_context, string_class: String)
      .perform_render.to_s.should contain("called from an auto-generated getter")
    OverrideGetterPage.new(build_context).perform_render.to_s.should eq("Joe")
    NonPageClass.new(param: "foo").param.should eq("foo")
    InheritedNonPageClass.new(param: "foo", other_param: "bar").other_param.should eq("bar")
  end
end
