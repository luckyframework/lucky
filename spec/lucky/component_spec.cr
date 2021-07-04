require "../spec_helper"

include ContextHelper

private class TestComponent < Lucky::BaseComponent
  def render
    text "TestComponent"
  end
end

private class ComplexTestComponent < Lucky::BaseComponent
  needs title : String

  def render
    text @title
    img src: asset("images/logo.png")
    mount(TestComponent)
  end
end

private class ComplexInstanceTestComponent < Lucky::BaseComponent
  needs title : String

  def render
    text @title
    img src: asset("images/logo.png")
    component = TestComponent.new
    mount_instance(component)
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

private class NoAction < TestAction
  get "/nothing_to_do" do
    plain_text "blip"
  end
end

private class ComponentWithAForm < Lucky::BaseComponent
  def render
    form_for NoAction do
    end
  end
end

private class TestMountPage
  include Lucky::HTMLPage

  def render
    mount(ComplexTestComponent, title: "passed_in_title")
    mount(ComponentWithBlockAndNoBlockArgs) do
      text "Block without args"
    end
    mount(ComponentWithBlock, "Jane") do |name|
      text name.upcase
    end
    mount(ComponentWithAForm)
    view
  end
end

private class TestMountInstancePage
  include Lucky::HTMLPage

  def render
    component = ComplexInstanceTestComponent.new(title: "passed_in_title")
    mount_instance(component)

    component = ComponentWithBlockAndNoBlockArgs.new
    mount_instance(component) do
      text "Block without args"
    end

    component = ComponentWithBlock.new("Jane")
    mount_instance(component) do |name|
      text name.upcase
    end

    view
  end
end

describe "components rendering" do
  it "renders to a page" do
    contents = TestMountPage.new(context_with_csrf).render.to_s

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
      contents = TestMountPage.new(context_with_csrf).render.to_s
      contents.should contain("<!-- BEGIN: ComplexTestComponent spec/lucky/component_spec.cr -->")
      contents.should contain("<!-- END: ComplexTestComponent -->")
      contents.should contain("<!-- BEGIN: ComponentWithBlock spec/lucky/component_spec.cr -->")
      contents.should contain("<!-- END: ComponentWithBlock -->")
    end
  end

  context "mounted instance" do
    it "renders to a page" do
      contents = TestMountInstancePage.new(build_context).render.to_s

      contents.should contain("passed_in_title")
      contents.should contain("TestComponent")
      contents.should contain("/images/logo-with-hash.png")
      contents.should contain("JANE")
      contents.should contain("Block without args")
      contents.should_not contain("<!--")
    end

    it "renders to a string" do
      html = ComplexInstanceTestComponent.new(title: "passed_in_title").render_to_string

      html.should contain("passed_in_title")
    end

    it "prints a comment when configured to do so" do
      Lucky::HTMLPage.temp_config(render_component_comments: true) do
        contents = TestMountInstancePage.new(build_context).render.to_s
        contents.should contain("<!-- BEGIN: ComplexInstanceTestComponent spec/lucky/component_spec.cr -->")
        contents.should contain("<!-- END: ComplexInstanceTestComponent -->")
        contents.should contain("<!-- BEGIN: ComponentWithBlock spec/lucky/component_spec.cr -->")
        contents.should contain("<!-- END: ComponentWithBlock -->")
      end
    end
  end

  it "uses context from being mounted" do
    contents = TestMountPage.new(context_with_csrf).render.to_s
    contents.should contain <<-HTML
    input type="hidden" name="_csrf"
    HTML
  end
end

private def context_with_csrf : HTTP::Server::Context
  context = build_context
  context.session.set(Lucky::ProtectFromForgery::SESSION_KEY, "my_token")
  context
end
