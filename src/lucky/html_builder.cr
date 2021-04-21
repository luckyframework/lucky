require "./tags/**"
require "./page_helpers/**"
require "./mount_component"

module Lucky::HTMLBuilder
  include Lucky::BaseTags
  include Lucky::CustomTags
  include Lucky::LinkHelpers
  include Lucky::FormHelpers
  include Lucky::SpecialtyTags
  include Lucky::AssetHelpers
  include Lucky::NumberToCurrency
  include Lucky::TextHelpers
  include Lucky::HTMLTextHelpers
  include Lucky::UrlHelpers
  include Lucky::TimeHelpers
  include Lucky::ForgeryProtectionHelpers
  include Lucky::MountComponent
  include Lucky::HelpfulParagraphError
  include Lucky::RenderIfDefined
  include Lucky::TagDefaults

  abstract def view

  def perform_render : IO
    render
    view
  end
end
