class Lucky::Params::UrlEncodedFormParams
  def value_at?(key : String | Symbol) : String?
    form_params[key]?
  end

  def hash_at?(nested_key : String | Symbol) : Hash(String, String)
    nested_form_params(nested_key.to_s).merge(nested_query_params(nested_key.to_s))
  end

  def array_at?(nested_key : String | Symbol) : Array(Hash(String, String))
    zipped_many_nested_params(nested_key.to_s).map do |a, b|
      (a || {} of String => String).merge(b || {} of String => String)
    end
  end

  private def nested_form_params(nested_key : String) : Hash(String, String)
    nested_key = "#{nested_key}:"
    form_params.to_h.reduce(empty_params) do |nested_params, (key, value)|
      if key.starts_with? nested_key
        nested_params[key.gsub(/^#{Regex.escape(nested_key)}/, "")] = value
      end

      nested_params
    end
  end

  private def zipped_many_nested_params(nested_key : String)
    body_params = many_nested_body_params(nested_key)
    query_params = many_nested_query_params(nested_key)

    if body_params.size > query_params.size
      body_params.zip?(query_params)
    else
      query_params.zip?(body_params)
    end
  end

  private def many_nested_body_params(nested_key : String) : Array(Hash(String, String))
    many_nested_form_params(nested_key.to_s)
  end

  private def many_nested_form_params(nested_key : String) : Array(Hash(String, String))
    source = multipart? ? multipart_params : form_params
    many_nested_hash_params(source.to_h, nested_key)
  end

  private def many_nested_hash_params(hash : Hash(String, String), nested_key : String) : Array(Hash(String, String))
    nested_key = "#{nested_key}["
    matcher = /^#{Regex.escape(nested_key)}(?<index>\d+)\]:(?<nested_key>.+)$/
    many_nested_params = Hash(String, Hash(String, String)).new do |h, k|
      h[k] ||= {} of String => String
    end

    hash.each do |key, value|
      if key.starts_with? nested_key
        key.match(matcher).try do |match|
          many_nested_params[match["index"]][match["nested_key"]] = value
        end
      end
    end

    many_nested_params.values
  end

  @_form_params : HTTP::Params?

  private def form_params
    @_form_params ||= HTTP::Params.parse(body)
  end
end
