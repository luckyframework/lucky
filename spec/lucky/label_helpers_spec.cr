require "../spec_helper"

include ContextHelper

class TestUser
  def first_name
    "My Name"
  end
end

class TestForm
  def first_name
    Avram::PermittedAttribute(String).new(
      name: :first_name,
      param: "",
      value: "",
      param_key: "user"
    )
  end
end

private class TestPage
  include Lucky::HTMLPage

  def render
  end

  def label_without_html_options
    label_for form.first_name, "First name"
  end

  def label_with_html_options
    label_for form.first_name, "First name", class: "best-label"
  end

  def label_with_block
    label_for form.first_name do
      strong "Have a thought?"
      text "Post here for others to see:"
    end
  end

  private def form
    TestForm.new
  end
end

describe Lucky::LabelHelpers do
  it "renders a label tag" do
    view.label_without_html_options.to_s.should contain <<-HTML
    <label for="user_first_name">First name</label>
    HTML

    view.label_with_html_options.to_s.should contain <<-HTML
    <label for="user_first_name" class="best-label">First name</label>
    HTML

    view.label_with_block.to_s.should contain <<-HTML
    <label for="user_first_name"><strong>Have a thought?</strong>Post here for others to see:</label>
    HTML
  end
end

private def view
  TestPage.new(build_context)
end
