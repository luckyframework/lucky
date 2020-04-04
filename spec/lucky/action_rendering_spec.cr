require "../spec_helper"

include ContextHelper

class Rendering::IndexPage
  include Lucky::HTMLPage

  needs title : String
  needs arg2 : String

  def render
    text @title
  end
end

class Rendering::Index < TestAction
  route do
    html title: "Anything", arg2: "testing multiple args"
  end
end

class Namespaced::Rendering::Index < TestAction
  route do
    html ::Rendering::IndexPage, title: "Anything", arg2: "testing multiple args"
  end
end

class Rendering::JSON::Index < TestAction
  route do
    json({name: "Paul"})
  end
end

class Rendering::JSON::WithStatus < TestAction
  get "/foo" do
    json({name: "Paul"}, status: 201)
  end
end

class Rendering::JSON::WithSymbolStatus < TestAction
  get "/foo" do
    json({name: "Paul"}, status: :created)
  end
end

class Rendering::HeadOnly < TestAction
  get "/foo" do
    head status: 204
  end
end

class Rendering::HeadOnly::WithSymbolStatus < TestAction
  get "/foo" do
    head status: :no_content
  end
end

class Rendering::Text::Index < TestAction
  route do
    plain_text "Anything"
  end
end

class Rendering::Text::WithStatus < TestAction
  get "/foo" do
    plain_text "Anything", status: 201
  end
end

class Rendering::Text::WithSymbolStatus < TestAction
  get "/foo" do
    plain_text "Anything", status: :created
  end
end

class Rendering::Xml::Index < TestAction
  get "/foo" do
    xml "<anything />"
  end
end

class Rendering::Xml::WithStatus < TestAction
  get "/foo" do
    xml "<anything />", status: 418
  end
end

class Rendering::Xml::WithSymbolStatus < TestAction
  get "/foo" do
    xml "<anything />", status: :im_a_teapot
  end
end

class Rendering::File < TestAction
  get "/file" do
    file "spec/fixtures/lucky_logo.png"
  end
end

class Rendering::File::Inline < TestAction
  get "/foo" do
    file "spec/fixtures/lucky_logo.png", disposition: "inline"
  end
end

class Rendering::File::CustomFilename < TestAction
  get "/foo" do
    file "spec/fixtures/lucky_logo.png",
      disposition: "attachment",
      filename: "custom.png"
  end
end

class Rendering::File::CustomContentType < TestAction
  get "/foo" do
    file "spec/fixtures/plain_text",
      disposition: "attachment",
      filename: "custom.html",
      content_type: "text/html"
  end
end

class Rendering::File::Missing < TestAction
  get "/foo" do
    file "new_file_who_dis"
  end
end

describe Lucky::Action do
  describe "rendering HTML pages" do
    it "render assigns" do
      response = Rendering::Index.new(build_context, params).call

      response.body.to_s.should contain "Anything"
      response.debug_message.to_s.should contain "Rendering::IndexPage"
    end
  end

  # See issue https://github.com/luckyframework/lucky/issues/678
  it "renders page classes when prefixed with ::" do
    response = Namespaced::Rendering::Index.new(build_context, params).call
    response.body.to_s.should contain "Anything"
  end

  it "renders JSON" do
    response = Rendering::JSON::Index.new(build_context, params).call
    response.body.to_s.should eq %({"name":"Paul"})
    response.status.should eq 200

    status = Rendering::JSON::WithStatus.new(build_context, params).call.status
    status.should eq 201

    status = Rendering::JSON::WithSymbolStatus.new(build_context, params).call.status
    status.should eq 201
  end

  it "renders XML" do
    response = Rendering::Xml::Index.new(build_context, params).call
    response.body.to_s.should eq %(<anything />)
    response.status.should eq 200

    status = Rendering::Xml::WithStatus.new(build_context, params).call.status
    status.should eq 418

    status = Rendering::Xml::WithSymbolStatus.new(build_context, params).call.status
    status.should eq 418
  end

  it "renders head response with no body" do
    response = Rendering::HeadOnly.new(build_context, params).call
    response.body.to_s.should eq ""
    response.status.should eq 204

    response = Rendering::HeadOnly::WithSymbolStatus.new(build_context, params).call
    response.status.should eq 204
  end

  it "renders text" do
    response = Rendering::Text::Index.new(build_context, params).call
    response.body.to_s.should eq "Anything"
    response.status.should eq 200

    response = Rendering::Text::WithStatus.new(build_context, params).call
    response.body.to_s.should eq "Anything"
    response.status.should eq 201

    response = Rendering::Text::WithSymbolStatus.new(build_context, params).call
    response.body.to_s.should eq "Anything"
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
