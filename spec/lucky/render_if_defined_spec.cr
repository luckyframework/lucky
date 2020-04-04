require "../spec_helper"

include ContextHelper

abstract class LayoutWithOptionalSidebar
  include Lucky::HTMLPage

  def render : String
    render_if_defined :sidebar
    view.to_s
  end
end

private class PageWithSidebar < LayoutWithOptionalSidebar
  def sidebar
    text "In the sidebar"
  end
end

private class PageWithoutSidebar < LayoutWithOptionalSidebar
end

describe "render_if_defined" do
  it "renders if the method is defined, otherwise it does nothing" do
    page_with_sidebar = PageWithSidebar.new(build_context)
    page_without_sidebar = PageWithoutSidebar.new(build_context)

    page_with_sidebar.render.to_s.should eq "In the sidebar"
    page_without_sidebar.render.to_s.should eq ""
  end
end
