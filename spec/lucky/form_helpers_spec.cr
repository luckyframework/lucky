require "../spec_helper"

include ContextHelper

class FormHelpers::Index < TestAction
  get "/form_helpers" { plain_text "foo " }
end

class FormHelpers::Update < TestAction
  put "/form_helpers/:id" { plain_text "foo " }
end

class FormHelpers::Create < TestAction
  post "/form_helpers" { plain_text "foo" }
end

private class TestPage
  include Lucky::HTMLPage

  def render
  end

  def inferred_put_form
    form_for FormHelpers::Update.with("fake_id") do
      text "foo"
    end
  end

  def inferred_post_form
    form_for FormHelpers::Create do
      text "foo"
    end
  end

  def inferred_get_form
    form_for FormHelpers::Index do
      text "foo"
    end
  end

  def form_with_html_options
    form_for FormHelpers::Create, class: "cool-form" do
      text "foo"
    end
  end

  def form_with_multipart
    form_for FormHelpers::Create, multipart: true do
      text "foo"
    end
  end

  def form_with_multipart_false
    form_for FormHelpers::Create, multipart: false do
      text "foo"
    end
  end

  def form_with_bool_attr
    form_for FormHelpers::Create, attrs: [:novalidate], class: "even-cooler-form" do
      text "foo"
    end
  end

  def form_wrapper(action : Lucky::Action.class)
    form_for action do
      yield
    end
  end
end

describe Lucky::FormHelpers do
  it "renders a form tag" do
    without_csrf_protection do
      view(&.inferred_put_form).should contain <<-HTML
      <form action="/form_helpers/fake_id" method="post"><input type="hidden" name="_method" value="put">foo</form>
      HTML

      view(&.inferred_post_form).should contain <<-HTML
      <form action="/form_helpers" method="post">foo</form>
      HTML

      view(&.inferred_get_form).should contain <<-HTML
      <form action="/form_helpers" method="get">foo</form>
      HTML

      view(&.form_with_html_options).should contain <<-HTML
      <form action="/form_helpers" method="post" class="cool-form">foo</form>
      HTML

      form = view(&.form_for(FormHelpers::Index) { })
      form.should contain <<-HTML
      <form action="/form_helpers" method="get"></form>
      HTML

      form = view(&.form_for(FormHelpers::Index, class: "form-block") { })
      form.should contain <<-HTML
      <form action="/form_helpers" method="get" class="form-block"></form>
      HTML

      view(&.form_with_bool_attr).should contain <<-HTML
      <form action="/form_helpers" method="post" class="even-cooler-form" novalidate>foo</form>
      HTML

      form = view do |page|
        page.form_wrapper(FormHelpers::Create) do
          page.text("purple")
        end
      end

      form.should contain <<-HTML
      <form action="/form_helpers" method="post">purple</form>
      HTML
    end
  end

  it "protects the form with a CSRF token" do
    context_with_csrf = build_context
    context_with_csrf.session.set(Lucky::ProtectFromForgery::SESSION_KEY, "my_token")

    form = view(context_with_csrf, &.form_for(FormHelpers::Index) { })

    form.should contain <<-HTML
    <form action="/form_helpers" method="get"><input type="hidden" name="#{Lucky::ProtectFromForgery::PARAM_KEY}" value="my_token"></form>
    HTML
  end

  it "converts the multipart argument" do
    without_csrf_protection do
      view(&.form_with_multipart).should contain <<-HTML
      <form action="/form_helpers" method="post" enctype="multipart/form-data">foo</form>
      HTML

      view(&.form_with_multipart_false).should contain <<-HTML
      <form action="/form_helpers" method="post">foo</form>
      HTML
    end
  end

  it "renders submit input" do
    view(&.submit("Save")).should contain <<-HTML
    <input type="submit" value="Save">
    HTML

    view(&.submit("Save", class: "cool")).should contain <<-HTML
    <input type="submit" value="Save" class="cool">
    HTML
  end

  it "renders submit input with attributes" do
    view(&.submit("Save", attrs: [:disabled])).should contain <<-HTML
    <input type="submit" value="Save" disabled>
    HTML

    view(&.submit("Save", class: "cool", attrs: [:hidden, :disabled])).should contain <<-HTML
    <input type="submit" value="Save" class="cool" hidden disabled>
    HTML
  end
end

private def without_csrf_protection
  Lucky::FormHelpers.temp_config(include_csrf_tag: false) do
    yield
  end
end

private def view(context : HTTP::Server::Context = build_context)
  TestPage.new(context).tap do |page|
    yield page
  end.view.to_s
end
