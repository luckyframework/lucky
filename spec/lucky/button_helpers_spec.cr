require "../../spec_helper"

private class TestPage
  include Lucky::HTMLPage

  def render
  end

  def submit_button
    button "Submit me!"
  end

  def reset_button
    button "Reset me!", type: "reset"
  end

  def disabled_button
    button "Hey there", disabled: "disabled"
  end

  def submit_button_with_block
    button do
      text "Hello"
    end
  end

  def raises_for_wrong_type
    button "Wrong", type: "fail"
  end
end

describe Lucky::ButtonHelpers do
  it "renders a submit button" do
    view.submit_button.to_s.should contain %(<button type="submit">Submit me!</button>)
  end

  it "renders a reset button" do
    view.reset_button.to_s.should contain %(<button type="reset">Reset me!</button>)
  end

  it "renders any attributes" do
    view.disabled_button.to_s.should contain %(<button type="submit" disabled="disabled">Hey there</button>)
  end

  it "renders any block content" do
    view.submit_button_with_block.to_s.should contain %(<button type="submit">Hello</button>)
  end

  it "raises for invalid types" do
    expect_raises Exception, "submit, reset or button" do
      view.raises_for_wrong_type
    end
  end
end

private def view
  TestPage.new(build_context)
end
