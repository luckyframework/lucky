require "../../spec_helper"

class TestUser
  def first_name
    "My Name"
  end
end

class TestForm
  def first_name
    field = LuckyRecord::Field(String).new(
      name: :first_name,
      param: "",
      value: "",
      form_name: "user"
    )
    LuckyRecord::AllowedField.new(field)
  end
end

private class TestPage
  include LuckyWeb::HTMLPage

  def render
  end

  def label_without_html_options
    label_for form.first_name
  end

  def label_with_html_options
    label_for form.first_name, class: "best-label"
  end

  private def form
    TestForm.new
  end
end

describe LuckyWeb::LabelHelpers do
  it "renders a label tag" do
    view.label_without_html_options.to_s.should contain <<-HTML
    <label>First name</label>
    HTML

    view.label_with_html_options.to_s.should contain <<-HTML
    <label class="best-label">First name</label>
    HTML
  end
end

private def view
  TestPage.new
end
