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
  include Lucky::TimeHelpers
  include Lucky::ForgeryProtectionHelpers
  include Lucky::MountComponent
  include Lucky::HelpfulParagraphError
  include Lucky::RenderIfDefined

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
      def initialize(
        {% for declaration in ASSIGNS %}
          {% var = declaration.var %}
          {% type = declaration.type %}
          {% has_default = declaration.value || declaration.value == nil %}
          {% if var.stringify.ends_with?("?") %}{{ var }}{% end %} @{{ var.stringify.gsub(/\?/, "").id }} : {{ type }}{% if has_default %} = {{ declaration.value }}{% end %},
        {% end %}
        )
      end
    {% end %}
  end

  def perform_render : IO::Memory
    render
    @view
  end
end
