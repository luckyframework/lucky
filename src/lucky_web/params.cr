class LuckyWeb::Params
  include LuckyRecord::Paramable

  @request : HTTP::Request
  @route_params : Hash(String, String) = {} of String => String

  getter :request
  getter :route_params

  def initialize(@request, @route_params = {} of String => String)
  end

  def get!(key) : String
    get(key) || raise "Missing parameter: #{key}"
  end

  def get(key : String | Symbol) : String?
    route_params[key.to_s]? || body_param(key.to_s) || query_params[key.to_s]?
  end

  def nested!(nested_key) : Hash(String, String)
    nested_params = nested(nested_key)
    if nested_params.keys.empty?
      raise "No nested params for: #{nested_key}"
    else
      nested_params
    end
  end

  def nested(nested_key : String | Symbol) : Hash(String, String)?
    nested_key = "#{nested_key}:"
    form_params.to_h.reduce(empty_params) do |nested_params, (key, value)|
      if key.starts_with? nested_key
        nested_params[key.gsub(/^#{Regex.escape(nested_key)}/, "")] = value
      end

      nested_params
    end
  end

  private def body_param(key : String)
    if json?
      parsed_json.as_h[key]?.try(&.to_s)
    else
      form_params[key]?
    end
  end

  @_form_params : HTTP::Params?
  private def form_params
    @_form_params ||= HTTP::Params.parse(body)
  end

  private def json?
    content_type == "application/json"
  end

  private def content_type : String?
    request.headers["Content-Type"]?
  end

  @_parsed_json : JSON::Any?
  private def parsed_json
    @_parsed_json ||= JSON.parse(body)
  end

  private def body
    (request.body || IO::Memory.new).gets_to_end.tap do |request_body|
      request.body = IO::Memory.new(request_body)
    end
  end

  private def empty_params
    {} of String => String
  end

  private def query_params
    request.query_params
  end
end
