class Lucky::Params::BodyParams
  alias ParamKey : ParamKey

  @request : HTTP::Request
  @route_params : Hash(String, String) = {} of String => String

  def initialize(@request, @route_params = {} of String => String)
  end

  abstract def top_level_body_params(key : ParamKey) : Hash(String, String)
  abstract def nested_body_params(key : ParamKey) : Hash(String, String)
  abstract def nested_array_body_params(key : ParamKey) : Array(Hash(String, String))
end
