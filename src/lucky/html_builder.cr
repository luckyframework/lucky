require "./tags/**"
require "./page_helpers/**"
require "./mount_component"

module Lucky::HTMLBuilder
  include Lucky::BaseTags
  include Lucky::CustomTags
  include Lucky::LinkHelpers
  include Lucky::FormHelpers
  include Lucky::LabelHelpers
  include Lucky::InputHelpers
  include Lucky::SelectHelpers
  include Lucky::SpecialtyTags
  include Lucky::Assignable
  include Lucky::AssetHelpers
  include Lucky::NumberToCurrency
  include Lucky::TextHelpers
  include Lucky::HTMLTextHelpers
  include Lucky::TimeHelpers
  include Lucky::ForgeryProtectionHelpers
  include Lucky::MountComponent
  include Lucky::HelpfulParagraphError
  include Lucky::RenderIfDefined
  include Lucky::WithDefaults

  abstract def view

  macro setup_initializer_hook
    macro finished
      generate_needy_initializer
    end

    macro included
      setup_initializer_hook
    end

    macro inherited
      setup_initializer_hook
    end
  end

  macro included
    setup_initializer_hook
  end

  macro generate_needy_initializer
    {% if !@type.abstract? %}
      {% sorted_assigns = ASSIGNS.sort_by { |dec|
           dec.type.resolve.nilable? || dec.value || dec.value == nil || dec.value == false ? 1 : 0
         } %}
      def initialize(
        {% for declaration in sorted_assigns %}
          {% var = declaration.var %}
          {% type = declaration.type %}
          {% value = declaration.value %}
          {% value = nil if type.stringify.ends_with?("Nil") && !value %}
          {% has_default = value || value == false || value == nil %}
          {% if false || var.stringify.ends_with?("?") %}{{ var }}{% end %} @{{ var.stringify.gsub(/\?/, "").id }} : {{ type }}{% if has_default %} = {{ value }}{% end %},
        {% end %}
        **unused_exposures
        )
      end
    {% end %}
  end

  def perform_render : IO
    render
    view
  end
end
