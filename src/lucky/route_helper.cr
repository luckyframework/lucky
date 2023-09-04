class Lucky::RouteHelper
  Habitat.create do
    setting base_uri : String
  end

  getter method : Symbol
  getter path : String

  def initialize(@method : Symbol, @path : String)
  end

  def url : String
    settings.base_uri + path
  end

  def_equals @method, @path
end
