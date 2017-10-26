class LuckyWeb::Params
  include LuckyRecord::Paramable

  @request : HTTP::Request
  @route_params : Hash(String, String) = {} of String => String

  getter :request
  getter :route_params

  def initialize(@request, @route_params = {} of String => String)
  end

  def get!(key)
    get(key) || raise "Missing parameter: #{key}"
  end

  def get(key : String | Symbol)
    route_params[key.to_s]? || form_params[key.to_s]? || query_params[key.to_s]?
  end

  def nested!(nested_key)
    nested_params = nested(nested_key)
    if nested_params.keys.empty?
      raise "No nested params for: #{nested_key}"
    else
      nested_params
    end
  end

  def nested(nested_key : String | Symbol)
    nested_key = "#{nested_key}:"
    form_params.to_h.reduce(empty_params) do |nested_params, (key, value)|
      if key.starts_with? nested_key
        nested_params[key.gsub(/^#{Regex.escape(nested_key)}/, "")] = value
      end

      nested_params
    end
  end

  @_params : HTTP::Params?
  private def form_params
    @_form_params ||= HTTP::Params.parse(body)
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
