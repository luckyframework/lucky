class LuckyWeb::Route
  getter :method, :path, :action

  def initialize(@method : Symbol, @path : String, @action : LuckyWeb::Action.class)
  end

  def_equals @method, @path, @action
end
