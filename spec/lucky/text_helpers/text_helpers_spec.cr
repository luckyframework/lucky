require "../../spec_helper"

private class TestPage
  include Lucky::HTMLPage

  def render
  end

  def test_truncate
    truncate "Hello World", length: 8 do
      link "Continue", "#"
    end
  end

  def test_highlight
    highlight "This is a beautiful morning, but also a beautiful day", "beautiful" do |word|
      span word, "data-highlight-word": word, "data-color": "yellow", "data-español": "bello"
    end
  end
end

def view
  TestPage.new
end
