require "../spec_helper"

include ContextHelper

class OnlyExpose < TestAction
  expose name

  get "/expose" do
    html OnlyExposePage
  end

  def name
    "Paul"
  end
end

class OnlyExposePage
  include Lucky::HTMLPage

  needs name : String

  def render
  end
end

abstract class BaseExposureAction < TestAction
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

  get "/multi_expose" do
    html arg1: "arg1", arg2: "arg2"
    html MultipleExposeAndAssignsPage, arg1: "arg1", arg2: "arg2"
  end

  def expose_three
    "expose_three"
  end
end

class MultipleExposeAndAssignsPage
  include Lucky::HTMLPage

  needs expose_one : String
  needs expose_two : String
  needs expose_three : String
  needs arg1 : String
  needs arg2 : String

  def render
  end
end

describe "exposures" do
  it "works without explicit assigns" do
    OnlyExpose.new(build_context, params).call
    MultipleExposeAndAssigns.new(build_context, params).call
  end
end
