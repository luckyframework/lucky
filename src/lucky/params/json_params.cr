class Lucky::Params::JsonParams < Lucky::Params::BodyParams
  def value_at?(key : String | Symbol) : String?
    parsed_json.as_h[key]?.try(&.to_s)
  end

  def hash_at?(key : String | Symbol) : Hash(String, String)
    nested_params = {} of String => String
    nested_key_json = parsed_json.as_h[key]? || JSON.parse("{}")

    nested_key_json.as_h.each do |key, value|
      nested_params[key.to_s] = value.to_s
    end

    nested_params
  end

  def array_at?(key : String | Symbol) : Array(Hash(String, String))
    array_of_params(key.to_s).map do |a, b|
      (a || {} of String => String).merge(b || {} of String => String)
    end
  end

  private def array_of_params(key : String) : Array(Hash(String, String))
    many_nested_params = [] of Hash(String, String)
    nested_key_json = parsed_json.as_h[key]? || JSON.parse("[]")

    nested_key_json.as_a.each do |nested_values|
      nested_params = {} of String => String
      nested_values.as_h.each do |key, value|
        nested_params[key.to_s] = value.to_s
      end

      many_nested_params << nested_params
    end

    many_nested_params
  end

  @_parsed_json : JSON::Any?

  private def parsed_json : JSON::Any
    @_parsed_json ||= begin
      if body.blank?
        JSON.parse("{}")
      else
        JSON.parse(body)
      end
    end
  end
end
