class LuckyWeb::Route
  getter :method, :action

  def initialize(@method : Symbol, @path : String, @action : LuckyWeb::Action.class)
  end

  def_equals @method, @path, @action

  def path
    "/#{method}/#{@path}"
  end
end
