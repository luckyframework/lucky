class LuckyWeb::Router
  INSTANCE = new

  getter :routes

  def initialize
    @tree = Radix::Tree(LuckyWeb::Action.class).new
    @routes = [] of LuckyWeb::Route
  end

  def self.add(method, path, action)
    INSTANCE.add(method, path, action)
  end

  def self.routes
    INSTANCE.routes
  end

  def add(method, path, action)
    route = LuckyWeb::Route.new(method, path, action)
    @routes << route
    @tree.add(route.path, route.action)
  end

  def find_action(path)
    @tree.find(path)
  end

  def self.find_action(path)
    INSTANCE.find_action(path)
  end
end
