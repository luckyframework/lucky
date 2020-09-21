require "../spec_helper"

private class TestTagDefaultsPage
  include Lucky::HTMLPage

  def render
    tag_defaults field: name_field, class: "form-control" do |tag_builder|
      tag_builder.text_input
    end

    tag_defaults field: name_field, class: "form-control" do |tag_builder|
      tag_builder.text_input placeholder: "Name please"
    end

    tag_defaults field: name_field, placeholder: "default" do |tag_builder|
      tag_builder.text_input placeholder: "replace default"
    end

    tag_defaults field: name_field, class: "default" do |tag_builder|
      tag_builder.text_input append_class: "appended classes"
    end

    tag_defaults field: name_field, class: "default" do |tag_builder|
      tag_builder.text_input replace_class: "replaced"
    end

    # No default 'class'
    tag_defaults field: name_field do |tag_builder|
      tag_builder.text_input append_class: "appended-without-default"
    end

    tag_defaults field: name_field do |tag_builder|
      tag_builder.text_input replace_class: "replaced-without-default"
    end

    # tags that have content
    tag_defaults class: "default" do |tag_builder|
      tag_builder.div "text content"
    end

    tag_defaults class: "default" do |tag_builder|
      tag_builder.div do
        text "block content"
      end
    end

    view
  end
end

describe "tag_defaults" do
  it "renders the component" do
    contents = TestTagDefaultsPage.new(build_context).render.to_s

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
    contents
      .should contain %(<input type="text" id="user_name" name="user:name" value="" class="appended-without-default">)
    contents
      .should contain %(<input type="text" id="user_name" name="user:name" value="" class="replaced-without-default">)
    contents
      .should contain %(<div class="default">text content</div>)
    contents
      .should contain %(<div class="default">block content</div>)
  end
end

private def name_field
  Avram::PermittedAttribute(String).new(
    name: :name,
    param: "",
    value: "",
    param_key: "user"
  )
end
