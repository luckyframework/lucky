# This file creates delegating modules for LuckyHtml that wrap the existing Lucky HTML functionality
# This allows LuckyHtml to be used as a standalone module while maintaining compatibility

require "../lucky"

# Delegate modules
module LuckyHtml::HTMLBuilder
  include Lucky::HTMLBuilder
end

module LuckyHtml::HTMLPage
  include Lucky::HTMLPage
end

abstract class LuckyHtml::BaseComponent < Lucky::BaseComponent
end

# Tag modules delegation
module LuckyHtml::BaseTags
  include Lucky::BaseTags
end

module LuckyHtml::CustomTags
  include Lucky::CustomTags
end

module LuckyHtml::SpecialtyTags
  include Lucky::SpecialtyTags
end

module LuckyHtml::TagDefaults
  include Lucky::TagDefaults
end

module LuckyHtml::LinkHelpers
  include Lucky::LinkHelpers
end

module LuckyHtml::FormHelpers
  include Lucky::FormHelpers
end

module LuckyHtml::ForgeryProtectionHelpers
  include Lucky::ForgeryProtectionHelpers
end

module LuckyHtml::LiveReloadTag
  include Lucky::LiveReloadTag
end

module LuckyHtml::CheckTagContent
  include Lucky::CheckTagContent
end

# Page helpers delegation
module LuckyHtml::HTMLTextHelpers
  include Lucky::HTMLTextHelpers
end

module LuckyHtml::TextHelpers
  include Lucky::TextHelpers
end

module LuckyHtml::NumberToCurrency
  include Lucky::NumberToCurrency
end

module LuckyHtml::TimeHelpers
  include Lucky::TimeHelpers
end

module LuckyHtml::RenderIfDefined
  include Lucky::RenderIfDefined
end

module LuckyHtml::SvgInliner
  include Lucky::SvgInliner
end

module LuckyHtml::HelpfulParagraphError
  include Lucky::HelpfulParagraphError
end

# Component helpers delegation
module LuckyHtml::MountComponent
  include Lucky::MountComponent
end