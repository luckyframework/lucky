require "../spec/spec_helper"

class OnlyExpose < LuckyWeb::Action
  include LuckyWeb::Exposeable

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

  assign name : String

  render do
  end
end

abstract class InheritedExposureAction < LuckyWeb::Action
  include LuckyWeb::Exposeable

  macro inherited
    expose :expose_one
  end

  def expose_one
    "expose_one"
  end
end

class MultipleExposeAndAssigns < InheritedExposureAction
  expose :expose_two

  get "/mutli-expose" do
    render arg1: "arg1", arg2: "arg2"
    render MultipleExposeAndAssignsPage, arg1: "arg1", arg2: "arg2"
  end

  def expose_two
    "expose_two"
  end
end

class MultipleExposeAndAssignsPage
  include LuckyWeb::Page

  assign expose_one : String
  assign expose_two : String
  assign arg1 : String
  assign arg2 : String

  render do
  end
end

describe "exposures" do
  it "works without explicit assigns" do
    OnlyExpose.new(context, params).call
    MultipleExposeAndAssigns.new(context, params).call
  end
end

private def context(path = "/")
  io = IO::Memory.new
  request = HTTP::Request.new("GET", path)
  response = HTTP::Server::Response.new(io)
  HTTP::Server::Context.new request, response
end

private def params
  {} of String => String
end
