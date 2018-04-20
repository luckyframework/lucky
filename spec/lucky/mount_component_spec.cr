require "../../spec_helper"

private abstract class BaseComponent(T)
  macro inherited
    forward_missing_to @page
  end
end

private class TestComponent(T) < BaseComponent(T)
  def initialize(@page : T)
  end

  def render
    text "TestComponent without args"
  end
end

private class TestComponentWithArgs(T) < BaseComponent(T)
  def initialize(@page : T, @title : String)
  end

  def render
    text "TestComponentWithArgs: #{@title}"
  end
end

private class TestMountPage
  include Lucky::HTMLPage

  def render
    mount TestComponent
    mount TestComponentWithArgs, "arg without keyword"
    mount TestComponentWithArgs, title: "arg with keyword"
  end
end

describe "mounting a component to a page" do
  it "renders the component" do
    contents = TestMountPage.new(build_context).render.to_s

    contents.should contain("TestComponent without args")
    contents.should contain("TestComponentWithArgs: arg without keyword")
    contents.should contain("TestComponentWithArgs: arg with keyword")
  end
end
