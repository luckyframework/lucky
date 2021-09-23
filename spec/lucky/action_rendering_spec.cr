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
  get "/rendering" do
    html title: "Anything", arg2: "testing multiple args"
  end
end

class Rendering::Show::WithStatus < TestAction
  get "/rendering/:nothing" do
    gather_status = 419
    html_with_status IndexPage, gather_status, title: "Closing Time", arg2: "You don't have to go home but you can't stay here"
  end
end

class Rendering::Show::WithSymbolStatus < TestAction
  get "/rendering1/:nothing" do
    html_with_status IndexPage, :unauthorized, title: "Closing Time", arg2: "You don't have to go home but you can't stay here"
  end
end

class Rendering::Show::WithEnumStatus < TestAction
  get "/rendering2/:nothing" do
    html_with_status IndexPage, HTTP::Status::UNPROCESSABLE_ENTITY, title: "Closing Time", arg2: "You don't have to go home but you can't stay here"
  end
end

class Namespaced::Rendering::Index < TestAction
  get "/namespaced/rendering" do
    html ::Rendering::IndexPage, title: "Anything", arg2: "testing multiple args"
  end
end

class Rendering::JSON::Index < TestAction
  get "/rendering/json" do
    json({name: "Paul"})
  end
end

class Rendering::JSON::WithRawStringBody < TestAction
  get "/foo" do
    raw_json("{\"name\":\"Paul\"}")
  end
end

class Rendering::JSON::WithRawStringBodyWithStatus < TestAction
  get "/bar" do
    raw_json("{\"name\":\"Paul\"}", status: 201)
  end
end

class Rendering::JSON::WithStatus < TestAction
  get "/foo1" do
    json({name: "Paul"}, status: 201)
  end
end

class Rendering::JSON::WithSymbolStatus < TestAction
  get "/foo2" do
    json({name: "Paul"}, status: :created)
  end
end

class Rendering::HeadOnly < TestAction
  get "/foo3" do
    head status: 204
  end
end

class Rendering::HeadOnly::WithSymbolStatus < TestAction
  get "/foo4" do
    head status: :no_content
  end
end

class Rendering::Text::Index < TestAction
  get "/rendering/text" do
    plain_text "Anything"
  end
end

class Rendering::Text::WithStatus < TestAction
  get "/foo5" do
    plain_text "Anything", status: 201
  end
end

class Rendering::Text::WithSymbolStatus < TestAction
  get "/foo6" do
    plain_text "Anything", status: :created
  end
end

class Rendering::Xml::Index < TestAction
  get "/foo7" do
    xml "<anything />"
  end
end

class Rendering::Xml::WithStatus < TestAction
  get "/foo8" do
    xml "<anything />", status: 418
  end
end

class Rendering::Xml::WithSymbolStatus < TestAction
  get "/foo9" do
    xml "<anything />", status: :im_a_teapot
  end
end

class Rendering::File < TestAction
  get "/file" do
    file "spec/fixtures/lucky_logo.png"
  end
end

class Rendering::File::Inline < TestAction
  get "/foo10" do
    file "spec/fixtures/lucky_logo.png", disposition: "inline"
  end
end

class Rendering::File::CustomFilename < TestAction
  get "/foo11" do
    file "spec/fixtures/lucky_logo.png",
      disposition: "attachment",
      filename: "custom.png"
  end
end

class Rendering::File::CustomContentType < TestAction
  get "/foo12" do
    file "spec/fixtures/plain_text",
      disposition: "attachment",
      filename: "custom.html",
      content_type: "text/html"
  end
end

class Rendering::File::Missing < TestAction
  get "/foo13" do
    file "new_file_who_dis"
  end
end

private class PlainTestComponent < Lucky::BaseComponent
  def render
    h1 "Plain Component"
  end
end

private class ComplexTestComponent < Lucky::BaseComponent
  needs title : String

  def render
    text @title
    img src: asset("images/logo.png")
    mount(PlainTestComponent)
  end
end

class Rendering::PlainComponent < TestAction
  get "/foo14" do
    component PlainTestComponent
  end
end

class Rendering::ComplexComponent < TestAction
  get "/foo15" do
    component ComplexTestComponent, title: "Getting Complex"
  end
end

class Rendering::PlainComponentWithCustomStatus < TestAction
  get "/foo16" do
    component PlainTestComponent, status: :partial_content
  end
end

describe Lucky::Action do
  describe "rendering HTML pages" do
    it "render assigns" do
      response = Rendering::Index.new(build_context, params).call

      response.body.to_s.should contain "Anything"
      response.debug_message.to_s.should contain "Rendering::IndexPage"
      response.status.should eq 200
    end

    it "renders with a different status code" do
      response = Rendering::Show::WithStatus.new(build_context, params).call

      response.body.to_s.should contain "Closing Time"
      response.debug_message.to_s.should contain "Rendering::IndexPage"
      response.status.should eq 419

      status = Rendering::Show::WithSymbolStatus.new(build_context, params).call.status
      status.should eq 401

      status = Rendering::Show::WithEnumStatus.new(build_context, params).call.status
      status.should eq 422
    end
  end

  describe "rendering Components" do
    it "renders a simple component" do
      response = Rendering::PlainComponent.new(build_context, params).call

      response.body.to_s.should eq "<h1>Plain Component</h1>"
    end

    it "renders a complex component" do
      response = Rendering::ComplexComponent.new(build_context, params).call

      body = response.body.to_s
      body.should contain "<h1>Plain Component</h1>"
      body.should contain "Getting Complex"
      body.should contain "images/logo-with-hash.png"
    end

    it "renders a component with a HTTP::Status" do
      response = Rendering::PlainComponentWithCustomStatus.new(build_context, params).call
      response.status.should eq 206
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

    response = Rendering::JSON::WithRawStringBody.new(build_context, params).call
    response.body.to_s.should eq %({"name":"Paul"})
    response.status.should eq 200

    response = Rendering::JSON::WithRawStringBodyWithStatus.new(build_context, params).call
    response.body.to_s.should eq %({"name":"Paul"})
    response.status.should eq 201

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
