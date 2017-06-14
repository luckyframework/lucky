require "./tags/**"

module LuckyWeb::Layout
  include LuckyWeb::LinkHelpers
  include LuckyWeb::BaseTags

  def initialize(@page, @view)
  end

  abstract def render

  macro render
    def render
      {{ yield }}
    end
  end
end
