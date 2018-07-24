require "../spec_helper"
include ContextHelper

private class TestPage
  include Lucky::HTMLPage

  def render
  end
end

describe Lucky::CustomTags do
  it "renders tag in a variety of ways" do
    view.tag("foo-tag", "content")
      .to_s.should contain "<foo-tag>content</foo-tag>"
    view.tag("foo-tag", 1)
      .to_s.should contain "<foo-tag>1</foo-tag>"
    view.tag("foo-tag", "content", class: "my-class")
      .to_s.should contain %(<foo-tag class="my-class">content</foo-tag>)
    view.tag("foo-tag", 1, class: "my-class")
      .to_s.should contain %(<foo-tag class="my-class">1</foo-tag>)
    view.tag("foo-tag", "content", data_confirm: "true")
      .to_s.should contain %(<foo-tag data-confirm="true">content</foo-tag>)
    view.tag("foo-tag")
      .to_s.should contain "<foo-tag></foo-tag>"
    view.tag("foo-tag", class: "my-class")
      .to_s.should contain %(<foo-tag class="my-class"></foo-tag>)
    view.tag("foo-tag", attrs: [:"ng-strict-di"], "ng-app": "ngAppStrictDemo")
      .to_s.should contain %(<foo-tag ng-app="ngAppStrictDemo" ng-strict-di></foo-tag>)

    view.tap do |page|
      page.tag("foo-tag") do
        page.text "content"
      end.to_s.should contain "<foo-tag>content</foo-tag>"
    end

    view.tap do |page|
      page.tag("foo-tag", class: "my-class") do
        page.text "content"
      end.to_s.should contain %(<foo-tag class="my-class">content</foo-tag>)
    end
  end
end

private def view
  TestPage.new(build_context)
end
