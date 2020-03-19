# :nodoc:
class Lucky::JsonBodyParser
  getter request : HTTP::Request

  def initialize(@request)
  end

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
