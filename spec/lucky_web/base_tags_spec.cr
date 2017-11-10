require "../../spec_helper"

private class TestPage
  include LuckyWeb::HTMLPage

  render do
  end
end

describe LuckyWeb::BaseTags do
  it "renders para tag as <p>" do
    view.para("foo").to_s.should contain "<p>foo</p>"
  end
end

private def view
  TestPage.new
end
