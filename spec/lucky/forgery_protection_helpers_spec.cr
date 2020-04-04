require "../spec_helper"

include ContextHelper

private class TestPage
  include Lucky::HTMLPage

  def render
  end
end

describe Lucky::ForgeryProtectionHelpers do
  it "renders a hidden input" do
    context = build_context
    context.session.set(Lucky::ProtectFromForgery::SESSION_KEY, "my_token")

    view(context, &.csrf_hidden_input).should contain <<-HTML
    <input type="hidden" name="#{Lucky::ProtectFromForgery::PARAM_KEY}" value="my_token">
    HTML
  end

  it "renders a meta tag for Rails UJS (and other JS that may need it)" do
    context = build_context
    context.session.set(Lucky::ProtectFromForgery::SESSION_KEY, "my_token")
    rendered = view(context, &.csrf_meta_tags)

    rendered.should contain <<-HTML
    <meta name="csrf-param" content="#{Lucky::ProtectFromForgery::PARAM_KEY}">
    HTML
    rendered.should contain <<-HTML
    <meta name="csrf-token" content="my_token">
    HTML
  end
end

private def view(context)
  TestPage.new(context).tap do |page|
    yield page
  end.view.to_s
end
