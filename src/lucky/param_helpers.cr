module Lucky::ParamHelpers
  @_params : Lucky::Params?

  def params : Lucky::Params
    @_params ||= Lucky::Params.new(context.request, @route_params)
  end

  # A shortcut for request.query_params
  #
  # Returns an `HTTP::Params` object for just query params.
  # This is rarely helpful since you can get query params with
  # `Lucky::Params#get`, but if you do need raw access to the query params
  # this is a good way to get them.
  def query_params : HTTP::Params
    request.query_params
  end

  @_parsed_json : JSON::Any?

  # Returns the parsed JSON or raises `Lucky::ParamParsingError` if JSON is not valid
  #
  # ```
  # # {"page": 1}
  # json_body["page"].as_i # 1
  # # {"users": [{"name": "Skyler"}]}
  # json_body["users"].as_a.first.["name"].as_s # "Skyler"
  # ```
  #
  # > You can also get JSON params with `Lucky::Params#get/nested`. Sometimes
  # > `Lucky::Params` are not flexible enough. In those cases this method opens
  # > the possiblity to do just about anything with JSON.
  def json_body : JSON::Any
    Lucky::JsonBodyParser.new(request).parsed_json
  end
end
