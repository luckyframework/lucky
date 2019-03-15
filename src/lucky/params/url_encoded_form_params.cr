class Lucky::Params::UrlEncodedFormParams
  def value_at?(key : String | Symbol) : String?
    route_params[key.to_s]? || body_param(key.to_s) || query_params[key.to_s]?
  end

  def hash_at?(nested_key : String | Symbol) : Hash(String, String)
    nested_form_params(nested_key.to_s).merge(nested_query_params(nested_key.to_s))
  end

  def array_at?(nested_key : String | Symbol) : Array(Hash(String, String))
    nested_params = many_nested?(nested_key)
    if nested_params.empty?
      raise Lucky::Exceptions::MissingNestedParam.new nested_key
    else
      nested_params
    end
  end

  def many_nested?(nested_key : String | Symbol) : Array(Hash(String, String))
    zipped_many_nested_params(nested_key.to_s).map do |a, b|
      (a || {} of String => String).merge(b || {} of String => String)
    end
  end

  private def nested_form_params(nested_key : String) : Hash(String, String)
    nested_key = "#{nested_key}:"
    source = multipart? ? multipart_params : form_params
    source.to_h.reduce(empty_params) do |nested_params, (key, value)|
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

  private def body_param(key : String)
    if multipart?
      multipart_params[key]?
    else
      form_params[key]?
    end
  end

  private def body_params
    if multipart?
      multipart_params
    else
      form_params
    end
  end

  @_form_params : HTTP::Params?

  private def form_params
    @_form_params ||= HTTP::Params.parse(body)
  end

  @_multipart_params : Hash(String, String)?

  private def multipart_params : Hash(String, String)
    @_multipart_params ||= parse_multipart_request.first
  end

  @_multipart_files : Hash(String, Lucky::UploadedFile)?

  private def multipart_files : Hash(String, Lucky::UploadedFile)
    @_multipart_files ||= parse_multipart_request.last
  end

  @_parsed_multipart_request : Tuple(Hash(String, String), Hash(String, Lucky::UploadedFile))?

  private def parse_multipart_request
    @_parsed_multipart_request ||= parse_form_data
  end

  private def parse_form_data
    multipart_params = {} of String => String
    multipart_files = {} of String => Lucky::UploadedFile
    body_io = IO::Memory.new(body)
    boundary =
      HTTP::Multipart.parse_boundary(request.headers["Content-Type"]).to_s
    HTTP::FormData.parse(body_io, boundary.to_s) do |part|
      case part.headers
      when .includes_word?("Content-Disposition", "filename")
        multipart_files[part.name] = Lucky::UploadedFile.new(part)
      else
        multipart_params[part.name] = part.body.gets_to_end
      end
    end
    {multipart_params, multipart_files}
  end
end
