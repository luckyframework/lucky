# Parse the body of an `HTTP::Request` to a `JSON::Any`
#
# > You can get the json body in `Lucky::Action` by calling `json_body`.
# > You can also get JSON params with `Lucky::Params#get/nested`.
# > You rarely need to use this class directly, but it is here if needed.
#
# Parsed the request body with `JSON.parse`. If the request body
# is empty (`""`) it will parse an empty object (`{}`) rather than raising.
#
# If the body is not valid JSON it will raise a `Lucky::ParamParsingError`
class Lucky::JsonBodyParser
  getter request : HTTP::Request

  def initialize(@request)
  end

  # Returns the parsed JSON or raises if JSON is not valid
  #
  # ```
  # json_body = Lucky::JsonBodyParser.new(request).parsed_json
  # # {"page": 1}
  # json_body["page"].as_i # 1
  # # {"users": [{"name": "Skyler"}]}
  # json_body["users"].as_a.first.["name"].as_s # "Skyler"
  # ```
  def parsed_json : JSON::Any
    if body.blank?
      JSON::Any.new({} of String => JSON::Any)
    else
      JSON.parse(body)
    end
  rescue JSON::ParseException
    raise Lucky::ParamParsingError.new(request)
  end

  private def body : String
    request.body.to_s
  end
end
