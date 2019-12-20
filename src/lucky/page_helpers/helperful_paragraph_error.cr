# :nodoc:
module Lucky::HelpfulParagraphError
  macro p(_arg, **args)
    {% raise <<-ERROR
      `p` is not available on Lucky pages. This is because it's not clear whether you want to print something out or use a `p` HTML tag.

      Instead try:
        * The `para` method if you want to use an HTML paragraph.
        * The `pp` method to pretty print information for debugging.
      ERROR
    %}
  end
end
