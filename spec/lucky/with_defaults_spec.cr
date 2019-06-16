require "../spec_helper"

private class TestWithDefaultsPage
  include Lucky::HTMLPage

  def render
    with_defaults field: name_field, class: "form-control" do |html|
      html.text_input
    end

    with_defaults field: name_field, class: "form-control" do |html|
      html.text_input placeholder: "Name please"
    end

    with_defaults field: name_field, placeholder: "default" do |html|
      html.text_input placeholder: "replace default"
    end

    with_defaults field: name_field, class: "default" do |html|
      html.text_input append_class: "appended classes"
    end

    with_defaults field: name_field, class: "default" do |html|
      html.text_input replace_class: "replaced"
    end

    view
  end
end

describe "with_defaults" do
  it "renders the component" do
    contents = TestWithDefaultsPage.new(build_context).render.to_s

    contents
      .should contain %(<input type="text" id="user_name" name="user:name" value="" class="form-control">)
    contents
      .should contain %(<input type="text" id="user_name" name="user:name" value="" class="form-control" placeholder="Name please">)
    contents
      .should contain %(<input type="text" id="user_name" name="user:name" value="" placeholder="replace default">)
    contents
      .should contain %(<input type="text" id="user_name" name="user:name" value="" class="default appended classes">)
    contents
      .should contain %(<input type="text" id="user_name" name="user:name" value="" class="replaced">)
  end
end

private def name_field
  Avram::PermittedAttribute(String).new(
    name: :name,
    param: "",
    value: "",
    form_name: "user"
  )
end
