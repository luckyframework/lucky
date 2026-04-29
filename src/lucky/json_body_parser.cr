# :nodoc:
class Lucky::JsonBodyParser
  getter body : String
  getter request : HTTP::Request

  def initialize(@body : String, @request : HTTP::Request)
  end

  def parsed_json : JSON::Any
    if body.blank?
      JSON::Any.new({} of String => JSON::Any)
    else
      JSON.parse(body)
    end
  rescue e : JSON::ParseException
    raise Lucky::ParamParsingError.new(@request, cause: e)
  end
end
