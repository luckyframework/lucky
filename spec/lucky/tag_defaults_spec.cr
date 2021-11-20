require "../spec_helper"

private class TestTagDefaultsPage
  include Lucky::HTMLPage

  def render
    tag_defaults do |tag_builder|
      tag_builder.div "text content"
    end

    tag_defaults class: "default" do |tag_builder|
      tag_builder.div "text content"
    end

    tag_defaults class: "default" do |tag_builder|
      tag_builder.div "text content", append_class: "appended classes"
    end

    tag_defaults class: "default" do |tag_builder|
      tag_builder.div "text content", replace_class: "replaced"
    end

    tag_defaults id: "foo" do |tag_builder|
      tag_builder.div "text content", append_class: "appended-without-default"
    end

    tag_defaults id: "foo" do |tag_builder|
      tag_builder.div "text content", replace_class: "replaced-without-default"
    end

    tag_defaults do |tag_builder|
      tag_builder.div do
        text "block content"
      end
    end

    tag_defaults do |tag_builder|
      tag_builder.div "@click": "onclick($event)" do
        text "block content"
      end
    end

    view
  end
end

include ContextHelper

describe "tag_defaults" do
  it "renders the component" do
    contents = TestTagDefaultsPage.new(build_context).render.to_s

    contents.should contain %(<div>text content</div>)
    contents.should contain %(<div class="default">text content</div>)
    contents.should contain %(<div class="default appended classes">text content</div>)
    contents.should contain %(<div class="replaced">text content</div>)
    contents.should contain %(<div id="foo" class="appended-without-default">text content</div>)
    contents.should contain %(<div id="foo" class="replaced-without-default">text content</div>)
    contents.should contain %(<div>block content</div>)
    contents.should contain %(<div @click="onclick($event)">block content</div>)
  end
end
