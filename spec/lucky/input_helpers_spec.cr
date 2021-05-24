require "../spec_helper"

include ContextHelper

class TestUser
  def first_name
    "My Name"
  end
end

class InputTestForm
  def first_name
    Avram::PermittedAttribute(String).new(
      name: :first_name,
      param: "My name",
      value: "",
      param_key: "user"
    )
  end

  def eula(value : String)
    Avram::PermittedAttribute(String).new(
      name: :eula,
      param: nil,
      value: value,
      param_key: "user"
    )
  end

  def admin(checked : Bool)
    Avram::PermittedAttribute(Bool).new(
      name: :admin,
      param: nil,
      value: checked,
      param_key: "user"
    )
  end

  def joined_at
    Avram::PermittedAttribute(Time).new(
      name: :joined_at,
      param: nil,
      value: Time.utc(2016, 2, 15, 10, 20, 30),
      param_key: "user"
    )
  end

  def status(value : String)
    Avram::PermittedAttribute(String).new(
      name: :status,
      param: nil,
      value: value,
      param_key: "user"
    )
  end
end

private class TestPage
  include Lucky::HTMLPage

  def render
  end
end

describe Lucky::InputHelpers do
  it "renders submit input" do
    view(&.submit("Save")).should contain <<-HTML
    <input type="submit" value="Save">
    HTML

    view(&.submit("Save", class: "cool")).should contain <<-HTML
    <input type="submit" value="Save" class="cool">
    HTML
  end

  describe "checkbox inputs" do
    it "works for non-booleans" do
      checked_field = form.eula("yes")
      view(&.checkbox(checked_field, checked_value: "yes", unchecked_value: "no")).should contain <<-HTML
      <input type="checkbox" id="user_eula" name="user:eula" value="yes" checked="true">
      HTML
      view(&.checkbox(checked_field, checked_value: "yes", unchecked_value: "no")).should contain <<-HTML
      <input type="hidden" id="" name="user:eula" value="no">
      HTML

      checked_field = form.eula("no")
      view(&.checkbox(checked_field, checked_value: "yes", unchecked_value: "no")).should contain <<-HTML
      <input type="checkbox" id="user_eula" name="user:eula" value="yes">
      HTML
      view(&.checkbox(checked_field, checked_value: "yes", unchecked_value: "no")).should contain <<-HTML
      <input type="hidden" id="" name="user:eula" value="no">
      HTML
    end

    it "sets checked and unchecked values for booleans automatically" do
      false_field = form.admin(false)
      view(&.checkbox(false_field)).should contain <<-HTML
      <input type="checkbox" id="user_admin" name="user:admin" value="true">
      HTML
      view(&.checkbox(false_field)).should contain <<-HTML
      <input type="hidden" id="" name="user:admin" value="false">
      HTML
      view(&.checkbox(false_field, attrs: [:checked])).should contain <<-HTML
      <input type="checkbox" id="user_admin" name="user:admin" value="true" checked>
      HTML

      true_field = form.admin(true)
      view(&.checkbox(true_field)).should contain <<-HTML
      <input type="checkbox" id="user_admin" name="user:admin" value="true" checked="true">
      HTML
      view(&.checkbox(true_field)).should contain <<-HTML
      <input type="hidden" id="" name="user:admin" value="false">
      HTML
      view(&.checkbox(true_field, attrs: [:required])).should contain <<-HTML
      <input type="checkbox" id="user_admin" name="user:admin" value="true" checked="true" required>
      HTML
    end
  end

  describe "radio inputs" do
    it "renders radio inputs" do
      radio_field = form.status("approved")

      rendered = view { |page|
        page.radio(radio_field, "approved")
        page.radio(radio_field, "unapproved")
      }
      rendered.should contain <<-HTML
      <input type="radio" id="user_status_approved" name="user:status" value="approved" checked="true">
      HTML

      rendered.should contain <<-HTML
      <input type="radio" id="user_status_unapproved" name="user:status" value="unapproved">
      HTML
    end

    it "renders radio inputs with boolean attrs" do
      radio_field = form.status("approved")

      view(&.radio(radio_field, "approved", attrs: [:required])).should contain <<-HTML
      <input type="radio" id="user_status_approved" name="user:status" value="approved" checked="true" required>
      HTML
    end
  end

  it "renders text inputs" do
    view(&.text_input(form.first_name)).should contain <<-HTML
    <input type="text" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view(&.text_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="text" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML

    view(&.text_input(form.first_name, attrs: [:required])).should contain <<-HTML
    <input type="text" id="user_first_name" name="user:first_name" value="My name" required>
    HTML
  end

  it "renders email inputs" do
    view(&.email_input(form.first_name)).should contain <<-HTML
    <input type="email" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view(&.email_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="email" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders file inputs" do
    view(&.file_input(form.first_name)).should contain <<-HTML
    <input type="file" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view(&.file_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="file" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders color inputs" do
    view(&.color_input(form.first_name)).should contain <<-HTML
    <input type="color" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view(&.color_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="color" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders hidden inputs" do
    view(&.hidden_input(form.first_name)).should contain <<-HTML
    <input type="hidden" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view(&.hidden_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="hidden" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders number inputs" do
    view(&.number_input(form.first_name)).should contain <<-HTML
    <input type="number" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view(&.number_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="number" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders telephone inputs" do
    view(&.telephone_input(form.first_name)).should contain <<-HTML
    <input type="tel" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view(&.telephone_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="tel" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders url inputs" do
    view(&.url_input(form.first_name)).should contain <<-HTML
    <input type="url" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view(&.url_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="url" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders search inputs" do
    view(&.search_input(form.first_name)).should contain <<-HTML
    <input type="search" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view(&.search_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="search" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML

    view(&.search_input(form.first_name, autofocus: true)).should contain <<-HTML
    <input type="search" id="user_first_name" name="user:first_name" value="My name" autofocus="true">
    HTML
  end

  it "renders password inputs" do
    view(&.password_input(form.first_name)).should contain <<-HTML
    <input type="password" id="user_first_name" name="user:first_name" value="">
    HTML

    view(&.password_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="password" id="user_first_name" name="user:first_name" value="" class="cool">
    HTML
  end

  it "renders range inputs" do
    view(&.range_input(form.first_name)).should contain <<-HTML
    <input type="range" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view(&.range_input(form.first_name, class: "cool")).should contain <<-HTML
    <input type="range" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders textareas" do
    view(&.textarea(form.first_name)).should contain <<-HTML
    <textarea id="user_first_name" name="user:first_name">My name</textarea>
    HTML

    view(&.textarea(form.first_name, class: "cool")).should contain <<-HTML
    <textarea id="user_first_name" name="user:first_name" class="cool">My name</textarea>
    HTML

    view(&.textarea(form.first_name, rows: 5, cols: 15)).should contain <<-HTML
    <textarea id="user_first_name" name="user:first_name" rows="5" cols="15">My name</textarea>
    HTML

    view(&.textarea(form.first_name, attrs: [:required])).should contain <<-HTML
    <textarea id="user_first_name" name="user:first_name" required>My name</textarea>
    HTML
  end

  it "renders time inputs" do
    view(&.time_input(form.joined_at)).should contain <<-HTML
    <input type="time" id="user_joined_at" name="user:joined_at" value="10:20:30">
    HTML

    view(&.time_input(form.joined_at, min: "09:00", max: "18:00")).should contain <<-HTML
    <input type="time" id="user_joined_at" name="user:joined_at" value="10:20:30" min="09:00" max="18:00">
    HTML

    view(&.time_input(form.joined_at, attrs: [:required], min: "09:00", max: "18:00")).should contain <<-HTML
    <input type="time" id="user_joined_at" name="user:joined_at" value="10:20:30" min="09:00" max="18:00" required>
    HTML
  end

  it "renders date inputs" do
    view(&.date_input(form.joined_at)).should contain <<-HTML
    <input type="date" id="user_joined_at" name="user:joined_at" value="2016-02-15">
    HTML

    view(&.date_input(form.joined_at, min: "2019-01-01", max: "2019-12-31")).should contain <<-HTML
    <input type="date" id="user_joined_at" name="user:joined_at" value="2016-02-15" min="2019-01-01" max="2019-12-31">
    HTML

    view(&.date_input(form.joined_at, attrs: [:required], min: "2019-01-01", max: "2019-12-31")).should contain <<-HTML
    <input type="date" id="user_joined_at" name="user:joined_at" value="2016-02-15" min="2019-01-01" max="2019-12-31" required>
    HTML
  end

  it "renders datetime-local inputs" do
    view(&.datetime_input(form.joined_at)).should contain <<-HTML
    <input type="datetime-local" id="user_joined_at" name="user:joined_at" value="2016-02-15T10:20:30">
    HTML

    view(&.datetime_input(form.joined_at, min: "2019-01-01T00:00:00", max: "2019-12-31T23:59:59")).should contain <<-HTML
    <input type="datetime-local" id="user_joined_at" name="user:joined_at" value="2016-02-15T10:20:30" min="2019-01-01T00:00:00" max="2019-12-31T23:59:59">
    HTML

    view(&.datetime_input(form.joined_at, attrs: [:required], min: "2019-01-01T00:00:00", max: "2019-12-31T23:59:59")).should contain <<-HTML
    <input type="datetime-local" id="user_joined_at" name="user:joined_at" value="2016-02-15T10:20:30" min="2019-01-01T00:00:00" max="2019-12-31T23:59:59" required>
    HTML
  end
end

private def form
  InputTestForm.new
end

private def view
  TestPage.new(build_context).tap do |page|
    yield page
  end.view.to_s
end

private def have_unchecked_value(value)
  contain <<-HTML
  <input type="hidden" id="" name="user:first_name" value="#{value}">
  HTML
end
