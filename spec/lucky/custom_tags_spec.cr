require "../spec_helper"

include ContextHelper

private class TestPage
  include Lucky::HTMLPage

  def render
  end
end

describe Lucky::CustomTags do
  it "renders tag in a variety of ways" do
    view(&.tag("foo-tag", "content"))
      .to_s.should contain "<foo-tag>content</foo-tag>"
    view(&.tag("foo-tag", 1))
      .to_s.should contain "<foo-tag>1</foo-tag>"
    view(&.tag("foo-tag", "content", class: "my-class"))
      .to_s.should contain %(<foo-tag class="my-class">content</foo-tag>)
    view(&.tag("foo-tag", 1, class: "my-class"))
      .to_s.should contain %(<foo-tag class="my-class">1</foo-tag>)
    view(&.tag("foo-tag", "content", data_confirm: "true"))
      .to_s.should contain %(<foo-tag data-confirm="true">content</foo-tag>)
    view(&.tag("foo-tag"))
      .to_s.should contain "<foo-tag></foo-tag>"
    view(&.tag("foo-tag", class: "my-class"))
      .to_s.should contain %(<foo-tag class="my-class"></foo-tag>)
    view(&.tag("foo-tag", {"class" => "my-class"}))
      .to_s.should contain %(<foo-tag class="my-class"></foo-tag>)
    view(&.tag("foo-tag", attrs: [:ng_strict_di], ng_app: "ngAppStrictDemo", name: "JSApp"))
      .to_s.should contain %(<foo-tag ng-app="ngAppStrictDemo" name="JSApp" ng-strict-di></foo-tag>)

    view do |page|
      page.tag("foo-tag") do
        page.text "content"
      end
    end.should contain "<foo-tag>content</foo-tag>"

    view do |page|
      page.tag("foo-tag", class: "my-class") do
        page.text "content"
      end
    end.should contain %(<foo-tag class="my-class">content</foo-tag>)

    view do |page|
      page.tag "script", [:async], data_counter: "https://counter.co", src: "count.js" do
      end
    end.should contain %(<script data-counter="https://counter.co" src="count.js" async></script>)
  end

  it "has a method for empty tags" do
    view(&.empty_tag("br")).should eq "<br>"
  end
end

private def view
  TestPage.new(build_context).tap do |page|
    yield page
  end.view.to_s
end
