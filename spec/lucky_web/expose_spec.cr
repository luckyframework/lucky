require "../spec/spec_helper"

include ContextHelper

class OnlyExpose < LuckyWeb::Action
  expose :name

  get "/expose" do
    render
    render OnlyExposePage
  end

  def name
    "Paul"
  end
end

class OnlyExposePage
  include LuckyWeb::Page

  needs name : String

  render do
  end
end

abstract class BaseExposureAction < LuckyWeb::Action
  expose :expose_one

  def expose_one
    "expose_one"
  end
end

abstract class InheritedExposureAction < BaseExposureAction
  expose :expose_two

  def expose_two
    "expose_two"
  end
end

class MultipleExposeAndAssigns < InheritedExposureAction
  expose :expose_three

  get "/mutli-expose" do
    render arg1: "arg1", arg2: "arg2"
    render MultipleExposeAndAssignsPage, arg1: "arg1", arg2: "arg2"
  end

  def expose_three
    "expose_three"
  end
end

class MultipleExposeAndAssignsPage
  include LuckyWeb::Page

  needs expose_one : String
  needs expose_two : String
  needs expose_three : String
  needs arg1 : String
  needs arg2 : String

  render do
  end
end

describe "exposures" do
  it "works without explicit assigns" do
    OnlyExpose.new(context, params).call
    MultipleExposeAndAssigns.new(context, params).call
  end
end
