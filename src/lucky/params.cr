require "tempfile"

class Lucky::Params
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

  def get_file(key : String | Symbol) : Tempfile?
    multipart_files[key.to_s]?
  end

  def nested!(nested_key) : Hash(String, String)
    nested_params = nested(nested_key)
    if nested_params.keys.empty?
      raise "No nested params for: #{nested_key}"
    else
      nested_params
    end
  end

  def nested(nested_key : String | Symbol) : Hash(String, String)
    if json?
      nested_json_params(nested_key.to_s)
    else
      nested_form_params(nested_key.to_s)
    end
  end

  def nested_json_params(nested_key : String) : Hash(String, String)
    nested_params = {} of String => String

    JSON::Any.new(parsed_json.as_h[nested_key]).each do |key, value|
      nested_params[key.to_s] = value.to_s
    end

    nested_params
  end

  def nested_form_params(nested_key : String) : Hash(String, String)
    nested_key = "#{nested_key}:"
    source = multipart? ? multipart_params : form_params
    source.to_h.reduce(empty_params) do |nested_params, (key, value)|
      if key.starts_with? nested_key
        nested_params[key.gsub(/^#{Regex.escape(nested_key)}/, "")] = value
      end

      nested_params
    end
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

  @_form_params : HTTP::Params?

  private def form_params
    @_form_params ||= HTTP::Params.parse(body)
  end

  @_multipart_params = {} of String => String

  private def multipart_params
    HTTP::FormData.parse(request) do |part|
      @_multipart_params[part.name] = part.body.gets_to_end
    end
    @_multipart_params
  end

  @_multipart_files = {} of String => Tempfile

  private def multipart_files
    HTTP::FormData.parse(request) do |part|
      part_file = Tempfile.open(part.name) do |tempfile|
        IO.copy(part.body, tempfile)
      end
      @_multipart_files[part.name] = part_file
    end
    @_multipart_files
  end

  private def json?
    content_type == "application/json"
  end

  private def multipart?
    content_type.try(&.match(/^multipart\/form-data/))
  end

  private def content_type : String?
    request.headers["Content-Type"]?
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
