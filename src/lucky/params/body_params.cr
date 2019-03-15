class Lucky::Params::BodyParams
  alias ParamKey : ParamKey

  @request : HTTP::Request
  @route_params : Hash(String, String) = {} of String => String

  def initialize(@request, @route_params = {} of String => String)
  end

  abstract def value_at(key : ParamKey) : String?
  abstract def hash_at(key : ParamKey) : Hash(String, String)?
  abstract def array_at(key : ParamKey) : Array(Hash(String, String))?
end
