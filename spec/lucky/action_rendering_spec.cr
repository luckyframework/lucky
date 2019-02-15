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
  route do
    render title: "Anything", arg2: "testing multiple args"
  end
end

class Namespaced::Rendering::Index < Lucky::Action
  route do
    render ::Rendering::IndexPage, title: "Anything", arg2: "testing multiple args"
  end
end

class Rendering::JSON::Index < Lucky::Action
  route do
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

class Rendering::Text::Index < Lucky::Action
  route do
    text "Anything"
  end
end

class Rendering::Text::WithStatus < Lucky::Action
  get "/foo" do
    text "Anything", status: 201
  end
end

class Rendering::Text::WithTypedStatus < Lucky::Action
  get "/foo" do
    text "Anything", status: Status::Created
  end
end

class Rendering::File < Lucky::Action
  get "/file" do
    file "spec/fixtures/lucky_logo.png"
  end
end

class Rendering::File::Inline < Lucky::Action
  get "/foo" do
    file "spec/fixtures/lucky_logo.png", disposition: "inline"
  end
end

class Rendering::File::CustomFilename < Lucky::Action
  get "/foo" do
    file "spec/fixtures/lucky_logo.png",
      disposition: "attachment",
      filename: "custom.png"
  end
end

class Rendering::File::CustomContentType < Lucky::Action
  get "/foo" do
    file "spec/fixtures/plain_text",
      disposition: "attachment",
      filename: "custom.html",
      content_type: "text/html"
  end
end

class Rendering::File::Missing < Lucky::Action
  get "/foo" do
    file "new_file_who_dis"
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

  # See issue https://github.com/luckyframework/lucky/issues/678
  it "renders page classes when prefixed with ::" do
    response = Namespaced::Rendering::Index.new(build_context, params).call
    response.body.should contain "Anything"
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

  it "renders text" do
    response = Rendering::Text::Index.new(build_context, params).call
    response.body.should eq "Anything"
    response.status.should eq 200

    response = Rendering::Text::WithStatus.new(build_context, params).call
    response.body.should eq "Anything"
    response.status.should eq 201

    response = Rendering::Text::WithTypedStatus.new(build_context, params).call
    response.body.should eq "Anything"
    response.status.should eq 201
  end

  it "renders files" do
    response = Rendering::File.new(build_context, params).call
    response.status.should eq 200
    response.disposition.should eq "attachment"
    response.content_type.should eq "image/png"

    response = Rendering::File::Inline.new(build_context, params).call
    response.status.should eq 200
    response.disposition.should eq "inline"
    response.content_type.should eq "image/png"

    response = Rendering::File::CustomFilename.new(build_context, params).call
    response.status.should eq 200
    response.disposition.should eq %(attachment; filename="custom.png")

    response = Rendering::File::CustomContentType.new(build_context, params).call
    response.status.should eq 200
    response.content_type.should eq "text/html"
  end
end
