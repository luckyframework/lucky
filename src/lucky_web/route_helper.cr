class LuckyWeb::RouteHelper
  getter path, method

  def initialize(@method : Symbol, @path : String)
  end

  def_equals @method, @path
end
