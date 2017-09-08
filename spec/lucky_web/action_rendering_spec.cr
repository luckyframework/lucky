require "../../spec_helper"

include ContextHelper

class Rendering::IndexPage
  include LuckyWeb::Page

  assign title : String
  assign arg2 : String

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
      body = Rendering::Index.new(context, params).call.body

      body.should eq "Anything"
    end
  end
end
