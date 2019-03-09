class Lucky::RouteHelper
  getter path, method

  Habitat.create do
    setting base_uri : String
  end

  def initialize(@method : Symbol, @path : String)
  end

  def url : String
    settings.base_uri + path
  end

  def_equals @method, @path
end
