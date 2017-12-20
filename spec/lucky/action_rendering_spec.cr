require "../../spec_helper"

include ContextHelper

class Rendering::IndexPage
  include Lucky::HTMLPage

  needs title : String
  needs arg2 : String

  def render
    text @title
  end
end

class Rendering::Index < Lucky::Action
  action do
    render title: "Anything", arg2: "testing multiple args"
  end
end

class Rendering::JSON::Index < Lucky::Action
  action do
    json({name: "Paul"})
  end
end

class Rendering::JSON::WithStatus < Lucky::Action
  get "/foo" do
    json({name: "Paul"}, status: 201)
  end
end

class Rendering::JSON::WithTypedStatus < Lucky::Action
  get "/foo" do
    json({name: "Paul"}, status: Status::Created)
  end
end

class Rendering::HeadOnly < Lucky::Action
  get "/foo" do
    head status: 204
  end
end

class Rendering::HeadOnly::WithTypedStatus < Lucky::Action
  get "/foo" do
    head status: Status::NoContent
  end
end

describe Lucky::Action do
  describe "rendering HTML pages" do
    it "render assigns" do
      response = Rendering::Index.new(build_context, params).call

      response.body.should contain "Anything"
      response.debug_message.to_s.should contain "Rendering::IndexPage"
    end
  end

  it "renders JSON" do
    response = Rendering::JSON::Index.new(build_context, params).call
    response.body.should eq %({"name":"Paul"})
    response.status.should eq 200

    status = Rendering::JSON::WithStatus.new(build_context, params).call.status
    status.should eq 201

    status = Rendering::JSON::WithTypedStatus.new(build_context, params).call.status
    status.should eq 201
  end

  it "renders head response with no body" do
    response = Rendering::HeadOnly.new(build_context, params).call
    response.body.should eq ""
    response.status.should eq 204

    response = Rendering::HeadOnly::WithTypedStatus.new(build_context, params).call
    response.status.should eq 204
  end
end
