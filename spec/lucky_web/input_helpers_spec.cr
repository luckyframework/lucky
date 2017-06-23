require "../../spec_helper"

class TestUser
  def first_name
    "My Name"
  end
end

class TestForm < LuckyRecord::Form(TestUser)
  allow :first_name

  def table_name
    "user"
  end

  def form_name
    "user"
  end

  def call
    first_name.param = "My name"
    self
  end

  add_fields [{name: first_name, type: LuckyRecord::StringType}]
end

private class TestPage
  include LuckyWeb::Page

  render do
  end

  def text_input_without_html_options
    text_input form.first_name
  end

  def text_input_with_html_options
    text_input form.first_name, class: "cool-input"
  end

  private def form
    TestForm.new.call
  end
end

describe LuckyWeb::LabelHelpers do
  it "renders text inputs" do
    view.text_input_without_html_options.to_s.should contain <<-HTML
    <input type="text" name="user:first_name" value="My name"/>
    HTML

    view.text_input_with_html_options.to_s.should contain <<-HTML
    <input type="text" name="user:first_name" value="My name" class="cool-input"/>
    HTML
  end

  it "renders email inputs" do
    view.email_input(form.first_name).to_s.should contain <<-HTML
    <input type="email" name="user:first_name" value="My name"/>
    HTML

    view.email_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="email" name="user:first_name" value="My name" class="cool"/>
    HTML
  end

  it "renders color inputs" do
    view.color_input(form.first_name).to_s.should contain <<-HTML
    <input type="color" name="user:first_name" value="My name"/>
    HTML

    view.color_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="color" name="user:first_name" value="My name" class="cool"/>
    HTML
  end

  it "renders hidden inputs" do
    view.hidden_input(form.first_name).to_s.should contain <<-HTML
    <input type="hidden" name="user:first_name" value="My name"/>
    HTML

    view.hidden_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="hidden" name="user:first_name" value="My name" class="cool"/>
    HTML
  end

  it "renders number inputs" do
    view.number_input(form.first_name).to_s.should contain <<-HTML
    <input type="number" name="user:first_name" value="My name"/>
    HTML

    view.number_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="number" name="user:first_name" value="My name" class="cool"/>
    HTML
  end

  it "renders telephone inputs" do
    view.telephone_input(form.first_name).to_s.should contain <<-HTML
    <input type="telephone" name="user:first_name" value="My name"/>
    HTML

    view.telephone_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="telephone" name="user:first_name" value="My name" class="cool"/>
    HTML
  end

  it "renders url inputs" do
    view.url_input(form.first_name).to_s.should contain <<-HTML
    <input type="url" name="user:first_name" value="My name"/>
    HTML

    view.url_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="url" name="user:first_name" value="My name" class="cool"/>
    HTML
  end

  it "renders search inputs" do
    view.search_input(form.first_name).to_s.should contain <<-HTML
    <input type="search" name="user:first_name" value="My name"/>
    HTML

    view.search_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="search" name="user:first_name" value="My name" class="cool"/>
    HTML
  end

  it "renders password inputs" do
    view.password_input(form.first_name).to_s.should contain <<-HTML
    <input type="password" name="user:first_name" value=""/>
    HTML

    view.password_input(form.first_name, class: "cool").to_s.should contain <<-HTML
    <input type="password" name="user:first_name" value="" class="cool"/>
    HTML
  end
end

private def form
  TestForm.new.call
end

private def view
  TestPage.new
end
