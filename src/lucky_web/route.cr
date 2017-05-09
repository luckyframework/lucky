class LuckyWeb::Route
  getter :method, :action

  def initialize(@method : Symbol, @path : String, @action : LuckyWeb::Action.class)
  end

  def_equals @method, @path, @action

  def path
    self.class.build_route_path(method, @path)
  end

  def self.build_route_path(method : Symbol, path : String)
    "/#{method}/#{path}"
  end
end
