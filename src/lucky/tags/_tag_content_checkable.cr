module Lucky::TagContentCheckable
  # If a tag has a nested tag (`IO`) or nil
  # then return that content.
  # ```
  # div { }
  # div { div { } }
  # div { text "" }
  # ```
  private def tag_content_check!(content : IO?)
    content
  end

  # A tag can only have another tag or nil as a
  # nested value. Anything else should raise a compile-time error
  # ```
  # div { "this will fail" }
  # ```
  private def tag_content_check!(content)
    {%
      raise <<-MESSAGE

      A tag in #{@type} has a nested String, but it must return a tag or `text`.

      If you want to display text, try this:

        div do
          text "my string"
        end
      MESSAGE
    %}
  end
end
