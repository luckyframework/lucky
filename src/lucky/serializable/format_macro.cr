module Lucky::Serializable
  # Macro for defining serializable format modules
  #
  # This macro generates a module that provides response methods for a specific serialization format.
  # It creates methods like `to_{format}_response` that can be included in serializer classes.
  #
  # ## Usage
  #
  # ```
  # Lucky::Serializable.define_format(
  #   name: "JSON",
  #   method: "to_json",
  #   content_type: "application/json"
  # )
  # ```
  #
  # This generates a `Lucky::Serializable::JSON` module with:
  # - `to_json_response(status : Int32 = 200) : Lucky::TextResponse`
  # - `to_json_response(status : HTTP::Status) : Lucky::TextResponse`
  #
  # ## Parameters
  #
  # - **name**: The module name (e.g., "JSON", "YAML", "CSV")
  # - **method**: The serialization method to call on the render data (e.g., "to_json", "to_yaml")
  # - **content_type**: The HTTP content type for responses (e.g., "application/json")
  # - **response_class**: Optional, defaults to `Lucky::TextResponse`
  # - **mime_type**: Optional, automatically registers the MIME type with Lucky
  #
  macro define_format(name, method, content_type, response_class = Lucky::TextResponse, mime_type = nil)
    {% format_name = name.id %}
    {% method_name = method.id %}
    {% response_method = "to_#{name.downcase.id}_response".id %}

    {% if mime_type %}
      Lucky::MimeType.register {{ content_type }}, {{ mime_type }}
    {% end %}

    module {{ format_name }}
      def {{ response_method }}(status : Int32 = 200) : {{ response_class.id }}
        begin
          serialized_data = render.{{ method_name }}
        rescue ex
          # Fallback to JSON if serialization fails
          Lucky::Log.warn { "Serialization failed for #{{{ method_name.stringify }}}: #{ex.message}, falling back to JSON" }
          serialized_data = render.to_json
        end

        {{ response_class.id }}.new(
          context,
          {{ content_type }},
          serialized_data,
          status: status,
          enable_cookies: enable_cookies?
        )
      end

      def {{ response_method }}(status : HTTP::Status) : {{ response_class.id }}
        {{ response_method }}(status.value)
      end
    end
  end

  # Define all built-in serialization formats
  define_format("JSON", "to_json", "application/json")
  define_format("YAML", "to_yaml", "application/yaml", mime_type: :yaml)
  define_format("MsgPack", "to_msgpack", "application/msgpack", mime_type: :msgpack)
  define_format("CSV", "to_csv", "text/csv")
  define_format("XML", "to_xml", "application/xml", mime_type: :xml)
end
