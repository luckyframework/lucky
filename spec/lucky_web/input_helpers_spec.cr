require "../../spec_helper"

class FormHelpers::Index < LuckyWeb::Action
  action { render_text "foo" }
end

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

  def call
  end

  add_fields [{name: first_name, type: LuckyRecord::StringType}]
end

private class TestPage
  include LuckyWeb::Page

  render do
  end

  def label_without_options
    label_for form.first_name
  end

  private def form
    TestForm.new
  end
end

describe LuckyWeb::FormHelpers do
  it "renders a form tag" do
    view.label_without_options.to_s.should contain <<-HTML
    <label>First name</label>
    HTML
  end
end

private def view
  TestPage.new
end
