require "./text_helpers_spec"

@[Lucky::SvgInliner::Path("spec/fixtures")]
module Lucky::SvgInliner
end

class TextHelperTestPage
  def with_inlined_svg
    inline_svg("lucky_logo.svg")
  end

  def with_inlined_and_styled_svg
    inline_svg("lucky_logo.svg", false)
  end
end

describe Lucky::SvgInliner do
  describe ".inline_svg" do
    it "inlines an svg in a page" do
      inlined_svg = view.tap(&.with_inlined_svg).render
      inlined_svg.should start_with %(<svg data-inline-svg="lucky_logo.svg")
      inlined_svg.should_not contain %(<?xml version="1.0" encoding="UTF-8"?>)
      inlined_svg.should_not contain %(<!-- lucky logo -->)
      inlined_svg.should_not contain "\n"
      inlined_svg.should_not contain %(fill="none" stroke="#2a2a2a" class="logo")
    end

    it "inlines an svg in a page with its original styling attributes" do
      inlined_svg = view.tap(&.with_inlined_and_styled_svg).render
      inlined_svg.should start_with %(<svg data-inline-svg-styled="lucky_logo.svg")
      inlined_svg.should contain %(fill="none" stroke="#2a2a2a" class="logo")
      inlined_svg.should_not contain %(<?xml version="1.0" encoding="UTF-8"?>)
      inlined_svg.should_not contain %(<!-- lucky logo -->)
      inlined_svg.should_not contain "\n"
    end
  end
end
