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

  def with_additional_attributes
    inline_svg("lucky_logo.svg", data_very: "lucky")
  end

  def with_original_styles_and_additional_attributes
    inline_svg("lucky_logo.svg", strip_styling: false, data_very: "lucky")
  end

  def without_file_extension
    inline_svg("lucky_logo")
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

    it "strips the xml declaration" do
      inlined_svg = view.tap(&.with_inlined_svg).render
      inlined_svg.should_not contain %(<?xml version="1.0" encoding="UTF-8"?>)
    end

    it "strips comments" do
      inlined_svg = view.tap(&.with_inlined_svg).render
      inlined_svg.should_not contain %(<!-- lucky logo -->)
    end

    it "strips newlines" do
      inlined_svg = view.tap(&.with_inlined_svg).render
      inlined_svg.should_not contain "\n"
    end

    it "strips styling attributes by default" do
      inlined_svg = view.tap(&.with_inlined_svg).render
      inlined_svg.should_not contain %(fill="none" stroke="#2a2a2a" class="logo")
    end

    it "allows inlining an svg without stripping its styling attributes" do
      inlined_svg = view.tap(&.with_inlined_and_styled_svg).render
      inlined_svg.should start_with %(<svg data-inline-svg-styled="lucky_logo.svg")
      inlined_svg.should contain %(fill="none" stroke="#2a2a2a" class="logo")
    end

    it "accepts additional arguments for aribitrary attributes" do
      inlined_svg = view.tap(&.with_additional_attributes).render
      inlined_svg.should contain %(data-very="lucky")
    end

    it "does not render the strip_styling option as attribute" do
      inlined_svg = view.tap(&.with_original_styles_and_additional_attributes).render
      inlined_svg.should contain %(data-very="lucky")
      inlined_svg.should_not contain %(strip-styling="false")
    end

    it "allows passing the svg path name without an extension" do
      inlined_svg = view.tap(&.without_file_extension).render
      inlined_svg.should start_with %(<svg data-inline-svg="lucky_logo.svg")
    end
  end
end
