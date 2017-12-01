require "./tags/**"
require "./page_helpers/**"
require "./time_helpers"

module Lucky::HTMLPage
  include Lucky::BaseTags
  include Lucky::ButtonHelpers
  include Lucky::LinkHelpers
  include Lucky::FormHelpers
  include Lucky::LabelHelpers
  include Lucky::InputHelpers
  include Lucky::SelectHelpers
  include Lucky::SpecialtyTags
  include Lucky::Assignable
  include Lucky::AssetHelpers
  include Lucky::NumberToCurrency
  include Lucky::TimeHelpers

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
        {% for var, type in ASSIGNS %}
          @{{ var }} : {{ type }},
        {% end %}
        )
      end
    {% end %}
  end

  macro render
    {% raise "Lucky now looks for a regular `def render` method. Please use that instead of `render do/end`" %}
  end

  def perform_render : IO::Memory
    render
    @view
  end

  macro p(_arg, **args)
    {% raise <<-ERROR
      `p` is not available on Lucky pages. This is because it's not clear whether you want to print something out or use a `p` HTML tag.

      Instead try:
        * The `para` method if you want to use an HTML paragraph.
        * The `pp` method to pretty print information for debugging.
      ERROR %}
  end
end
