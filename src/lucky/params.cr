class Lucky::Params
  include Avram::Paramable
  include Lucky::Memoizable

  @request : HTTP::Request
  @route_params : Hash(String, String) = {} of String => String

  alias MultipartParams = Hash(String, String)
  alias MultipartFiles = Hash(String, Lucky::UploadedFile)

  # :nodoc:
  private getter :request
  # :nodoc:
  private getter :route_params

  # Create a new params object
  #
  # The params object is initialized with an `HTTP::Request` and a hash of
  # params. The request object has many optional parameters. See Crystal's
  # [HTTP::Request](https://crystal-lang.org/api/latest/HTTP/Request.html)
  # class for more details.
  #
  # ```crystal
  # request = HTTP::Request.new("GET", "/")
  # route_params = {"token" => "123"}
  #
  # Lucky::Params.new(request, route_params)
  # ```
  def initialize(@request, @route_params = {} of String => String)
  end

  # Parses the request body as `JSON::Any` or raises `Lucky::ParamParsingError` if JSON is invalid.
  #
  # ```crystal
  # # {"page": 1}
  # params.from_json["page"].as_i # 1
  # # {"users": [{"name": "Skyler"}]}
  # params.from_json["users"][0]["name"].as_s # "Skyler"
  # ```
  #
  # See the crystal docs on
  # [`JSON::Any`](https://crystal-lang.org/api/JSON/Any.html) for more on using
  # JSON in Crystal.
  #
  # > You can also get JSON params with `Lucky::Params#get/nested`. Sometimes
  # > `Lucky::Params` are not flexible enough. In those cases this method opens
  # > the possiblity to do just about anything with JSON.
  def from_json : JSON::Any
    parsed_json
  end

  # Returns just the query params as `HTTP::Params`
  #
  # Returns an `HTTP::Params` object for only the query params. This method is rarely
  # helpful since you can get query params with `get`, but if you do need raw
  # access to the query params this is the way to get them.
  #
  # ```crystal
  # params.from_query["search"] # Will return the "search" query param
  # ```
  #
  # See the docs on [`HTTP::Params`](https://crystal-lang.org/api/HTTP/Params.html) for more information.
  def from_query : HTTP::Params
    request.query_params
  end

  # Returns x-www-form-urlencoded body params as `HTTP::Params`
  #
  # Returns an `HTTP::Params` object for the request body. This method is rarely
  # helpful since you can get query params with `get`, but if you do need raw
  # access to the body params this is the way to get them.
  #
  # ```crystal
  # params.from_form_data["name"]
  # ```
  #
  # See the docs on [`HTTP::Params`](https://crystal-lang.org/api/HTTP/Params.html) for more information.
  def from_form_data : HTTP::Params
    form_params
  end

  # Returns multipart params and files.
  #
  # Return a Tuple with a hash of params and a hash of `Lucky::UploadedFile`.
  # This method is rarely helpful since you can get params with `get` and files
  # with `get_file`, but if you need something more custom you can use this method
  # to get better access to the raw params.
  #
  # ```crystal
  # form_params = params.from_multipart.last # Hash(String, String)
  # form_params["name"]                      # "Kyle"
  #
  # files = params.from_multipart.last # Hash(String, Lucky::UploadedFile)
  # files["avatar"]                    # Lucky::UploadedFile
  # ```
  def from_multipart : Tuple(MultipartParams, MultipartFiles)
    parse_multipart_request
  end

  # Retrieve a value from the params hash, raise if key is absent
  #
  # If no key is found a `Lucky::MissingParamError` will be raised:
  #
  # ```crystal
  # params.get("page")    # 1 : String
  # params.get("missing") # Missing parameter: missing
  # ```
  def get(key) : String
    get?(key) || raise Lucky::MissingParamError.new(key.to_s)
  end

  # Retrieve a value from the params hash, return nil if key is absent
  #
  # ```crystal
  # params.get?("missing") # nil : (String | Nil)
  # params.get?("page")    # 1 : (String | Nil)
  # ```
  def get?(key : String | Symbol) : String?
    route_params[key.to_s]? || body_param(key.to_s) || query_params[key.to_s]?
  end

  # Retrieve a file from the params hash, raise if key is absent
  #
  # If no key is found a `Lucky::MissingParamError` will be raised:
  #
  # ```crystal
  # params.get_file("missing") # Raise: Missing parameter: missing
  #
  # file = params.get_file("avatar_file") # Lucky::UploadedFile
  # file.name                             # avatar.png
  # file.metadata                         # HTTP::FormData::FileMetadata
  # file.tempfile.read                    # Get the file contents
  # ```
  def get_file(key) : Lucky::UploadedFile
    get_file?(key) || raise Lucky::MissingParamError.new(key.to_s)
  end

  # Retrieve a file from the params hash, return nil if key is absent
  #
  # ```crystal
  # params.get_file?("missing") # nil
  #
  # file = params.get_file?("avatar_file") # Lucky::UploadedFile
  # file.not_nil!.name                     # avatar.png
  # file.not_nil!.metadata                 # HTTP::FormData::FileMetadata
  # file.not_nil!.tempfile.read            # Get the file contents
  # ```
  def get_file?(key : String | Symbol) : Lucky::UploadedFile?
    multipart_files[key.to_s]?
  end

  # Retrieve a nested value from the params
  #
  # Nested params often appear in JSON requests or Form submissions. If no key
  # is found a `Lucky::MissingParamError` will be raised:
  #
  # ```crystal
  # body = "user:name=Alesia&user:age=35&page=1"
  # request = HTTP::Request.new("POST", "/", body: body)
  # params = Lucky::Params.new(request)
  #
  # params.nested("user")    # {"name" => "Alesia", "age" => "35"}
  # params.nested("missing") # Missing parameter: missing
  # ```
  def nested(nested_key : String | Symbol) : Hash(String, String)
    nested_params = nested?(nested_key)
    if nested_params.keys.empty?
      raise Lucky::MissingNestedParamError.new nested_key
    else
      nested_params
    end
  end

  # Retrieve a nested value from the params
  #
  # Nested params often appear in JSON requests or Form submissions. If no key
  # is found an empty hash will be returned:
  #
  # ```crystal
  # body = "user:name=Alesia&user:age=35&page=1"
  # request = HTTP::Request.new("POST", "/", body: body)
  # params = Lucky::Params.new(request)
  #
  # params.nested("user")    # {"name" => "Alesia", "age" => "35"}
  # params.nested("missing") # {}
  # ```
  def nested?(nested_key : String | Symbol) : Hash(String, String)
    if json?
      nested_json_params(nested_key.to_s).merge(nested_query_params(nested_key.to_s))
    else
      nested_form_params(nested_key.to_s).merge(nested_query_params(nested_key.to_s))
    end
  end

  # Retrieve a nested file from the params
  #
  # Nested params often appear in JSON requests or Form submissions. If no key
  # is found a `Lucky::MissingParamError` will be raised:
  #
  # ```crystal
  # params.nested_file?("file")    # Lucky::UploadedFile
  # params.nested_file?("missing") # {}
  # ```
  def nested_file(nested_key : String | Symbol) : Hash(String, Lucky::UploadedFile)
    nested_file_params = nested_file?(nested_key)
    if nested_file_params.keys.empty?
      raise Lucky::MissingNestedParamError.new nested_key
    else
      nested_file_params
    end
  end

  # Retrieve a nested file from the params
  #
  # Nested params often appear in JSON requests or Form submissions. If no key
  # is found an empty hash will be returned:
  #
  # ```crystal
  # params.nested_file("file")    # Lucky::UploadedFile
  # params.nested_file("missing") # Missing parameter: missing
  # ```
  def nested_file?(nested_key : String | Symbol) : Hash(String, Lucky::UploadedFile)?
    nested_file_params(nested_key.to_s)
  end

  # Retrieve nested values from the params
  #
  # Nested params often appear in JSON requests or Form submissions. If no key
  # is found a `Lucky::MissingParamError` will be raised:
  #
  # ```crystal
  # body = "users[0]:name=Alesia&users[0]:age=35&users[1]:name=Bob&users[1]:age=40&page=1"
  # request = HTTP::Request.new("POST", "/", body: body)
  # params = Lucky::Params.new(request)
  #
  # params.many_nested("users")
  # # [{"name" => "Alesia", "age" => "35"}, { "name" => "Bob", "age" => "40" }]
  # params.many_nested("missing") # Missing parameter: missing
  # ```
  def many_nested(nested_key : String | Symbol) : Array(Hash(String, String))
    nested_params = many_nested?(nested_key)
    if nested_params.empty?
      raise Lucky::MissingNestedParamError.new nested_key
    else
      nested_params
    end
  end

  # Retrieve nested values from the params
  #
  # Nested params often appear in JSON requests or Form submissions. If no key
  # is found an empty array will be returned:
  #
  # ```crystal
  # body = "users[0]:name=Alesia&users[0]:age=35&users[1]:name=Bob&users[1]:age=40&page=1"
  # request = HTTP::Request.new("POST", "/", body: body)
  # params = Lucky::Params.new(request)
  #
  # params.nested("users")
  # # [{"name" => "Alesia", "age" => "35"}, { "name" => "Bob", "age" => "40" }]
  # params.nested("missing") # []
  # ```
  def many_nested?(nested_key : String | Symbol) : Array(Hash(String, String))
    zipped_many_nested_params(nested_key.to_s).map do |a, b|
      (a || {} of String => String).merge(b || {} of String => String)
    end
  end

  # Converts the params in to a `Hash(String, String)`
  #
  # ```crystal
  # request.query = "filter:name=trombone&page=1&per=50"
  # params = Lucky::Params.new(request)
  # params.to_h # {"filter" => {"name" => "trombone"}, "page" => "1", "per" => "50"}
  # ```
  def to_h
    if json?
      parsed_json.as_h.merge(query_params.to_h)
    else
      hash = {} of String => String | Hash(String, String)
      params = body_params.to_h.merge(query_params.to_h)
      params.map do |key, value|
        keys = key.split(':')
        is_nested = keys.size > 1
        if is_nested
          hash[keys.first] = nested(keys.first)
        else
          hash[key] = value.as(String)
        end
      end
      hash
    end
  end

  private def nested_json_params(nested_key : String) : Hash(String, String)
    nested_params = {} of String => String
    nested_key_json = parsed_json.as_h[nested_key]? || JSON.parse("{}")

    nested_key_json.as_h.each do |key, value|
      nested_params[key.to_s] = value.to_s
    end

    nested_params
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

  private def nested_query_params(nested_key : String) : Hash(String, String)
    nested_key = "#{nested_key}:"
    query_params.to_h.reduce(empty_params) do |nested_params, (key, value)|
      if key.starts_with? nested_key
        nested_params[key.gsub(/^#{Regex.escape(nested_key)}/, "")] = value
      end

      nested_params
    end
  end

  private def nested_file_params(nested_key : String) : Hash(String, Lucky::UploadedFile)
    nested_key = "#{nested_key}:"
    multipart_files.to_h.reduce(empty_file_params) do |nested_params, (key, value)|
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
    if json?
      many_nested_json_params(nested_key.to_s)
    else
      many_nested_form_params(nested_key.to_s)
    end
  end

  private def many_nested_json_params(nested_key : String) : Array(Hash(String, String))
    many_nested_params = [] of Hash(String, String)
    nested_key_json = parsed_json.as_h[nested_key]? || JSON.parse("[]")

    nested_key_json.as_a.each do |nested_values|
      nested_params = {} of String => String
      nested_values.as_h.each do |key, value|
        nested_params[key.to_s] = value.to_s
      end

      many_nested_params << nested_params
    end

    many_nested_params
  end

  private def many_nested_form_params(nested_key : String) : Array(Hash(String, String))
    source = multipart? ? multipart_params : form_params
    many_nested_hash_params(source.to_h, nested_key)
  end

  private def many_nested_query_params(nested_key : String) : Array(Hash(String, String))
    many_nested_hash_params(query_params.to_h, nested_key)
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
    if json?
      parsed_json.as_h[key]?.try(&.to_s)
    elsif multipart?
      multipart_params[key]?
    else
      form_params[key]?
    end
  end

  private def body_params
    if json?
      parsed_json.as_h
    elsif multipart?
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

  private def parse_form_data : Tuple(MultipartParams, MultipartFiles)
    multipart_params = MultipartParams.new
    multipart_files = MultipartFiles.new
    body_io = IO::Memory.new(body)

    boundary = MIME::Multipart.parse_boundary(request.headers["Content-Type"]).to_s

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

  private def json?
    content_type.try(&.match(/^application\/json/))
  end

  private def multipart?
    content_type.try(&.match(/^multipart\/form-data/))
  end

  private def content_type : String?
    request.headers["Content-Type"]?
  end

  private memoize def parsed_json : JSON::Any
    Lucky::JsonBodyParser.new(request).parsed_json
  end

  memoize def body : String
    Lucky::RequestBodyReader.new(request).body
  end

  private def empty_params
    {} of String => String
  end

  private def empty_file_params
    {} of String => Lucky::UploadedFile
  end

  private def query_params
    request.query_params
  end
end
