require "../../spec_helper"

class TextHelperTestPage
  include Lucky::HTMLPage

  def render
  end
end

def view
  TextHelperTestPage.new
end
