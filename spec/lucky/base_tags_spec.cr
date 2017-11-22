require "../../spec_helper"

private class TestPage
  include Lucky::HTMLPage

  def render
  end
end

class MySpecialClass
  include Lucky::AllowedInTags

  def to_s
    "it works"
  end
end

describe Lucky::BaseTags do
  it "renders para tag as <p>" do
    view.para("foo").to_s.should contain "<p>foo</p>"
  end

  it "renders allowed types in tags" do
    view.para(42).to_s.should contain "<p>42</p>"
    view.para(MySpecialClass.new).to_s.should contain "<p>it works</p>"
    view.para(1_i64).to_s.should contain "<p>1</p>"
  end
end

private def view
  TestPage.new
end
