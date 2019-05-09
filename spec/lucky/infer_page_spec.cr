require "../spec_helper"

class Rendering::CustomPage
  include Lucky::HTMLPage

  needs title : String
  needs arg2 : String

  def render
    text @title
  end
end

class Rendering::Foo < Lucky::Action
  get "/foo" do
    render Rendering::CustomPage, title: "EditPage", arg2: "testing_multiple_args"
  end
end

class Rendering::WithinSameNameSpace < Lucky::Action
  get "/in-namespace" do
    render CustomPage, title: "WithinSameNameSpace", arg2: "testing_multiple_args"
  end
end

describe Lucky::Action do
  it "renders fully qualified pages" do
    body = Rendering::Foo.new(build_context, params).call.body

    body.should contain "EditPage"
  end

  it "renders within the same namespace" do
    body = Rendering::WithinSameNameSpace.new(build_context, params).call.body

    body.should contain "WithinSameNameSpace"
  end
end
