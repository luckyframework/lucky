require "./input_helpers"
require "./label_helpers"
require "./select_helpers"

module Lucky::HTMLBuilder
  include Lucky::InputHelpers
  include Lucky::LabelHelpers
  include Lucky::SelectHelpers
end
