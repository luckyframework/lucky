require "../spec_helper"

class Rendering::CustomPage
  include Lucky::HTMLPage

  needs title : String
  needs arg2 : String

  def render
    text @title
  end
end

class Rendering::Foo < TestAction
  get "/rendering_foo" do
    html Rendering::CustomPage, title: "EditPage", arg2: "testing_multiple_args"
  end
end

class Rendering::WithinSameNameSpace < TestAction
  get "/in_namespace" do
    html CustomPage, title: "WithinSameNameSpace", arg2: "testing_multiple_args"
  end
end

describe Lucky::Action do
  it "renders fully qualified pages" do
    body = Rendering::Foo.new(build_context, params).call.body.to_s

    body.should contain "EditPage"
  end

  it "renders within the same namespace" do
    body = Rendering::WithinSameNameSpace.new(build_context, params).call.body.to_s

    body.should contain "WithinSameNameSpace"
  end
end
