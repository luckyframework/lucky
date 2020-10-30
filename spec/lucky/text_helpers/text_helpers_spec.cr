require "../../spec_helper"

include ContextHelper

class TextHelperTestPage
  include Lucky::HTMLPage

  def render
    view.to_s
  end
end

def view
  TextHelperTestPage.new(build_context)
end
