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
      form_name: "user"
    )
  end

  def eula(value : String)
    Avram::PermittedAttribute(String?).new(
      name: :eula,
      param: nil,
      value: value,
      form_name: "user"
    )
  end

  def admin(checked : Bool)
    Avram::PermittedAttribute(Bool?).new(
      name: :admin,
      param: nil,
      value: checked,
      form_name: "user"
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
    view.submit("Save").to_s.should contain <<-HTML
    <input type="submit" value="Save">
    HTML

    view.submit("Save", class: "cool").to_s.should contain <<-HTML
    <input type="submit" value="Save" class="cool">
    HTML
  end

  describe "checkbox inputs" do
    it "works for non-booleans" do
      checked_field = form.eula("yes")
      view.checkbox(checked_field, checked_value: "yes", unchecked_value: "no").to_s.should contain <<-HTML
      <input type="checkbox" id="user_eula" name="user:eula" value="yes" checked="true">
      HTML
      view.checkbox(checked_field, checked_value: "yes", unchecked_value: "no").to_s.should contain <<-HTML
      <input type="hidden" id="" name="user:eula" value="no">
      HTML

      checked_field = form.eula("no")
      view.checkbox(checked_field, checked_value: "yes", unchecked_value: "no").to_s.should contain <<-HTML
      <input type="checkbox" id="user_eula" name="user:eula" value="yes">
      HTML
      view.checkbox(checked_field, checked_value: "yes", unchecked_value: "no").to_s.should contain <<-HTML
      <input type="hidden" id="" name="user:eula" value="no">
      HTML
    end

    it "sets checked and unchecked values for booleans automatically" do
      false_field = form.admin(false)
      view.checkbox(false_field).to_s.should contain <<-HTML
      <input type="checkbox" id="user_admin" name="user:admin" value="true">
      HTML
      view.checkbox(false_field).to_s.should contain <<-HTML
      <input type="hidden" id="" name="user:admin" value="false">
      HTML

      true_field = form.admin(true)
      view.checkbox(true_field).to_s.should contain <<-HTML
      <input type="checkbox" id="user_admin" name="user:admin" value="true" checked="true">
      HTML
      view.checkbox(true_field).to_s.should contain <<-HTML
      <input type="hidden" id="" name="user:admin" value="false">
      HTML
    end
  end

  it "renders text inputs" do
    view.text_input(form.first_name).to_s.should contain <<-HTML
    <input type="text" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view.text_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="text" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML

    view.text_input(form.first_name, attrs: [:required]).to_s.should contain <<-HTML
    <input type="text" id="user_first_name" name="user:first_name" value="My name" required>
    HTML
  end

  it "renders email inputs" do
    view.email_input(form.first_name).to_s.should contain <<-HTML
    <input type="email" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view.email_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="email" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders file inputs" do
    view.file_input(form.first_name).to_s.should contain <<-HTML
    <input type="file" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view.file_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="file" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders color inputs" do
    view.color_input(form.first_name).to_s.should contain <<-HTML
    <input type="color" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view.color_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="color" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders hidden inputs" do
    view.hidden_input(form.first_name).to_s.should contain <<-HTML
    <input type="hidden" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view.hidden_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="hidden" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders number inputs" do
    view.number_input(form.first_name).to_s.should contain <<-HTML
    <input type="number" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view.number_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="number" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders telephone inputs" do
    view.telephone_input(form.first_name).to_s.should contain <<-HTML
    <input type="tel" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view.telephone_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="tel" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders url inputs" do
    view.url_input(form.first_name).to_s.should contain <<-HTML
    <input type="url" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view.url_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="url" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders search inputs" do
    view.search_input(form.first_name).to_s.should contain <<-HTML
    <input type="search" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view.search_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="search" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML

    view.search_input(form.first_name, autofocus: true).to_s.should contain <<-HTML
    <input type="search" id="user_first_name" name="user:first_name" value="My name" autofocus="true">
    HTML
  end

  it "renders password inputs" do
    view.password_input(form.first_name).to_s.should contain <<-HTML
    <input type="password" id="user_first_name" name="user:first_name" value="">
    HTML

    view.password_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="password" id="user_first_name" name="user:first_name" value="" class="cool">
    HTML
  end

  it "renders range inputs" do
    view.range_input(form.first_name).to_s.should contain <<-HTML
    <input type="range" id="user_first_name" name="user:first_name" value="My name">
    HTML

    view.range_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="range" id="user_first_name" name="user:first_name" value="My name" class="cool">
    HTML
  end

  it "renders textareas" do
    view.textarea(form.first_name).to_s.should contain <<-HTML
    <textarea id="user_first_name" name="user:first_name">My name</textarea>
    HTML

    view.textarea(form.first_name, class: "cool").to_s.should contain <<-HTML
    <textarea id="user_first_name" name="user:first_name" class="cool">My name</textarea>
    HTML

    view.textarea(form.first_name, rows: 5, cols: 15).to_s.should contain <<-HTML
    <textarea id="user_first_name" name="user:first_name" rows="5" cols="15">My name</textarea>
    HTML
  end
end

private def form
  InputTestForm.new
end

private def view
  TestPage.new(build_context)
end

private def have_unchecked_value(value)
  contain <<-HTML
  <input type="hidden" id="" name="user:first_name" value="#{value}">
  HTML
end
