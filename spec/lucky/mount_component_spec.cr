require "../../spec_helper"

private abstract class BaseComponent
  include Lucky::HTMLBuilder

  needs view : IO::Memory
end

private class TestComponent < BaseComponent
  def render
    text "TestComponent without args"
  end
end

private class TestComponentWithArgs < BaseComponent
  needs title : String

  def render
    text "TestComponentWithArgs: #{@title}"
  end
end

private class ComplexTestComponent < BaseComponent
  needs title : String

  def render
    text @title
    img src: asset("images/logo.png")
    mount TestComponent
  end
end

private class ComponentWithBlock < BaseComponent
  needs name : String

  def render
    yield @name
  end
end

private class TestMountPage
  include Lucky::HTMLPage

  def render
    mount TestComponent
    mount TestComponentWithArgs, "arg without keyword"
    mount TestComponentWithArgs, title: "arg with keyword"
    mount ComplexTestComponent, title: "arg with keyword"
    mount ComponentWithBlock, "jane" do |name|
      text name.upcase
    end
    mount ComponentWithBlock, name: "joe" do |name|
      text name.upcase
    end
    @view
  end
end

describe "mounting a component to a page" do
  it "renders the component" do
    contents = TestMountPage.new(build_context).render.to_s

    contents.should contain("TestComponent without args")
    contents.should contain("TestComponentWithArgs: arg without keyword")
    contents.should contain("TestComponentWithArgs: arg with keyword")
    contents.should contain("/images/logo-with-hash.png")
    contents.should contain("JOE")
    contents.should contain("JANE")
  end
end
