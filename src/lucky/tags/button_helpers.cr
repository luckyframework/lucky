require "./link_helpers"

module Lucky::ButtonHelpers
  include Lucky::LinkHelpers
  EMPTY_HTML_ATTRS = {} of String => String
  DEFAULT_TYPE_ATTR = {"type" => "submit"}
  VALID_TYPES = ["submit", "reset", "button"]

  def button(
      content : Lucky::AllowedInTags | String? = "",
      options = EMPTY_HTML_ATTRS,
      **other_options
    )
    merged_options = merge_options(merge_options(other_options, options), DEFAULT_TYPE_ATTR)
    button_tag(merged_options) do
      text content
    end
  end

  def button(content : String | Lucky::AllowedInTags)
    button_tag(DEFAULT_TYPE_ATTR) do
      text content
    end
  end

  def button(&block)
    button_tag(DEFAULT_TYPE_ATTR) do
      yield
    end
  end

  private def button_tag(content : String, options = EMPTY_HTML_ATTRS)
    button_tag options do
      text content
    end
  end

  private def button_tag(options : Hash(String, String), &block)
    validate_type(options)
    @view << "<button" << build_tag_attrs(options) << ">"
    yield
    @view << "</button>"
  end

  private def validate_type(options : Hash(String, String))
    unless VALID_TYPES.includes?(options["type"]?)
      raise <<-ERROR
      "#{options["type"]?}" is not a valid type for a <button/> element. Please use one of submit, reset or button.
      ERROR
    end
  end
end
