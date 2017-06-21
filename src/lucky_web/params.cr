class LuckyWeb::Params
  @request : HTTP::Request
  @params : HTTP::Params?

  getter :request

  def initialize(@request)
  end

  def get!(key)
    get(key) || raise "Missing parameter: #{key}"
  end

  def get(key : String | Symbol)
    params[key.to_s]? || query_params[key.to_s]?
  end

  def nested_in!(nested_key)
    nested_params = nested_in(nested_key)
    if nested_params.keys.empty?
      raise "No nested params for: #{nested_key}"
    else
      nested_params
    end
  end

  def nested_in(nested_key : String | Symbol)
    nested_key = "#{nested_key}:"
    params.to_h.reduce(empty_params) do |nested_params, (key, value)|
      if key.starts_with? nested_key
        nested_params[key.gsub(/^#{Regex.escape(nested_key)}/, "")] = value
      end

      nested_params
    end
  end

  private def params
    @params ||= HTTP::Params.parse(body)
  end

  private def body
    (request.body || IO::Memory.new).gets_to_end
  end

  private def empty_params
    {} of String => String
  end

  private def query_params
    request.query_params
  end
end
