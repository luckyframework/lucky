class Lucky::RouteHelper
  getter path, method

  Habitat.create do
    setting domain : String
  end

  def initialize(@method : Symbol, @path : String)
  end

  def url
    settings.domain + path
  end

  def_equals @method, @path
end
