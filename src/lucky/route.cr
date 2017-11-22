class Lucky::Route
  getter :method, :path, :action

  def initialize(@method : Symbol, @path : String, @action : Lucky::Action.class)
  end

  def_equals @method, @path, @action
end
