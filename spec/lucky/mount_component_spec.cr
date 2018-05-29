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
  alias RenderableProc = Proc(String, Nil)
  needs name : String
  needs block : RenderableProc

  def render
    @block.call(@name)
  end
end

private class ComponentWithOptionalBlock < BaseComponent
  alias RenderableProc = Proc(Nil)
  needs block : RenderableProc? = nil

  def render
    block = @block
    if block
      block.call
    else
      text "No block given"
    end
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
    mount ComponentWithOptionalBlock
    mount ComponentWithOptionalBlock do
      text "Added a block"
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
    contents.should contain("No block given")
    contents.should contain("Added a block")
  end
end
