require "../spec_helper"

include ContextHelper

private class TestComponent < Lucky::BaseComponent
  def render
    text "TestComponent"
  end
end

private class ComplexTestComponent < Lucky::BaseComponent
  needs extra_css : String?
  needs title : String

  def render
    text @title
    img src: asset("images/logo.png")
    mount TestComponent.new
  end
end

private class ComponentWithBlock < Lucky::BaseComponent
  needs name : String

  def render
    yield @name
  end
end

private class ComponentWithBlockAndNoBlockArgs < Lucky::BaseComponent
  def render
    yield
  end
end

private class TestMountPage
  include Lucky::HTMLPage

  def render
    mount ComplexTestComponent.new(title: "passed_in_title")
    mount ComponentWithBlockAndNoBlockArgs.new do
      text "Block without args"
    end
    mount ComponentWithBlock.new("jane") do |name|
      text name.upcase
    end
    view
  end
end

describe "components rendering" do
  it "renders to a page" do
    contents = TestMountPage.new(build_context).render.to_s

    contents.should contain("passed_in_title")
    contents.should contain("TestComponent")
    contents.should contain("/images/logo-with-hash.png")
    contents.should contain("JANE")
    contents.should contain("Block without args")
    contents.should_not contain("<!--")
  end

  it "renders to a string" do
    html = ComplexTestComponent.new(title: "passed_in_title").render_to_string

    html.should contain("passed_in_title")
  end

  it "prints a comment when configured to do so" do
    Lucky::HTMLPage.temp_config(render_component_comments: true) do
      contents = TestMountPage.new(build_context).render.to_s
      contents.should contain("<!-- Started: ComplexTestComponent -->")
      contents.should contain("<!-- Finished: ComplexTestComponent -->")
      contents.should contain("<!-- Started: ComponentWithBlock -->")
      contents.should contain("<!-- Finished: ComponentWithBlock -->")
    end
  end
end
