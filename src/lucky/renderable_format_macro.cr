module Lucky::Renderable
  # Macro for generating format methods in Renderable module
  #
  # This macro creates the methods needed to render a specific format directly in actions.
  # It generates content type helpers and format methods with status code support.
  #
  # ## Usage
  #
  # ```
  # Lucky::Renderable.define_renderable_format(
  #   name: "xml",
  #   content_type: "application/xml",
  #   method: "to_xml"
  # )
  # ```
  #
  # This generates:
  # - `xml_content_type : String` method
  # - `xml(body : String, ...)` for pre-serialized strings
  # - `xml(body, ...)` for objects that respond to the method
  # - HTTP::Status overloads
  #
  macro define_renderable_format(name, content_type, method)
    {% format_name = name.id %}
    {% method_name = method.id %}
    {% content_type_method = "#{name.id}_content_type".id %}

    def {{ content_type_method }} : String
      {{ content_type }}
    end

    def {{ format_name }}(body : String, status : Int32? = nil, content_type : String = {{ content_type_method }}) : Lucky::TextResponse
      send_text_response(body, content_type, status)
    end

    def {{ format_name }}(body, status : Int32? = nil, content_type : String = {{ content_type_method }}) : Lucky::TextResponse
      if body.responds_to?({{ method.symbolize }})
        {{ format_name }}(body.{{ method_name }}, status, content_type)
      else
        # Fallback to JSON with warning
        Lucky::Log.warn { "Object does not respond to #{{{ method.stringify }}}, falling back to JSON" }
        {{ format_name }}(body.to_json, status, content_type)
      end
    end

    def {{ format_name }}(body, status : HTTP::Status, content_type : String = {{ content_type_method }}) : Lucky::TextResponse
      {{ format_name }}(body, status: status.value, content_type: content_type)
    end
  end
end
