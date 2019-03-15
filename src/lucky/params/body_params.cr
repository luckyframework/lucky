class Lucky::Params::BodyParams
  alias ParamKey : String | Symbol

  @request : HTTP::Request
  @route_params : Hash(String, String) = {} of String => String

  def initialize(@request, @route_params = {} of String => String)
  end

  abstract def value_at?(key : ParamKey) : String?
  abstract def hash_at?(key : ParamKey) : Hash(String, String)?
  abstract def array_at?(key : ParamKey) : Array(Hash(String, String))?

  private def body
    (request.body || IO::Memory.new).gets_to_end.tap do |request_body|
      request.body = IO::Memory.new(request_body)
    end
  end
end
