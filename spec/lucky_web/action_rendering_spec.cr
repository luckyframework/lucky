require "../../spec_helper"

include ContextHelper

class Rendering::IndexPage
  include LuckyWeb::HTMLPage

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

class Rendering::JSON::Index < LuckyWeb::Action
  action do
    json({name: "Paul"})
  end
end

class Rendering::JSON::WithStatus < LuckyWeb::Action
  get "/foo" do
    json({name: "Paul"}, status: 201)
  end
end

class Rendering::HeadOnly < LuckyWeb::Action
  get "/foo" do
    head status: 204
  end
end

describe LuckyWeb::Action do
  describe "rendering HTML pages" do
    it "render assigns" do
      body = Rendering::Index.new(build_context, params).call.body

      body.should contain "Anything"
    end
  end

  it "renders JSON" do
    response = Rendering::JSON::Index.new(build_context, params).call
    response.body.should eq %({"name":"Paul"})
    response.status.should eq 200

    status = Rendering::JSON::WithStatus.new(build_context, params).call.status
    status.should eq 201
  end

  it "renders head response with no body" do
    response = Rendering::HeadOnly.new(build_context, params).call
    response.body.should eq ""
    response.status.should eq 204
  end
end
