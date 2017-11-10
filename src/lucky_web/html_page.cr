require "./tags/**"

module LuckyWeb::HTMLPage
  include LuckyWeb::BaseTags
  include LuckyWeb::ButtonHelpers
  include LuckyWeb::LinkHelpers
  include LuckyWeb::FormHelpers
  include LuckyWeb::LabelHelpers
  include LuckyWeb::InputHelpers
  include LuckyWeb::SelectHelpers
  include LuckyWeb::SpecialtyTags
  include LuckyWeb::Assignable
  include LuckyWeb::AssetHelpers

  macro generate_initializer
    def initialize(
      {% for var, type in ASSIGNS %}
        @{{ var }} : {{ type }},
      {% end %}
      )
    end
  end

  macro render
    def render
      {{ yield }}
      @view
    end

    generate_initializer
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
