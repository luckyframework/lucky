require "../../spec_helper"

include ContextHelper

class Rendering::IndexPage
  include LuckyWeb::Page

  needs title : String
  needs arg2 : String

  render do
    text @title
  end
end

class Rendering::Index < LuckyWeb::Action
  action do
    render title: "Anything", arg2: "testing multiple args"
  end
end

describe LuckyWeb::Action do
  describe "rendering" do
    it "render assigns" do
      body = Rendering::Index.new(build_context, params).call.body

      body.should contain "Anything"
    end
  end
end
