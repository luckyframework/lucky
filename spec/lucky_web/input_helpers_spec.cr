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
  it "renders a label tag" do
    view.text_input_without_html_options.to_s.should contain <<-HTML
    <input type="text" name="user:first_name" value="My name"/>
    HTML

    view.text_input_with_html_options.to_s.should contain <<-HTML
    <input type="text" name="user:first_name" value="My name" class="cool-input"/>
    HTML
  end
end

private def view
  TestPage.new
end
