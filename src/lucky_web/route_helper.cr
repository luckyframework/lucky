class LuckyWeb::RouteHelper
  def initialize(@method : Symbol, @path : String)
  end

  def_equals @method, @path
end
