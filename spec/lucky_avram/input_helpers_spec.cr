require "../spec_helper"
include ContextHelper

private class TestPage
  include Lucky::HTMLPage

  def render
  end
end

describe Lucky::InputHelpers do
  it "generates the proper name for array attributes" do
    view { |page|
      page.text_input(array_attribute)
      page.text_input(array_attribute)
      page.text_input(array_attribute)
    }.should contain <<-HTML
    <input type="text" id="key_group_0" name="key:group[]" value="one"><input type="text" id="key_group_1" name="key:group[]" value="two"><input type="text" id="key_group_2" name="key:group[]" value="">
    HTML
  end
end

private def array_attribute
  Avram::PermittedAttribute.new(name: :group, param: nil, value: ["one", "two"], param_key: "key")
end

private def view
  TestPage.new(build_context).tap do |page|
    yield page
  end.view.to_s
end
