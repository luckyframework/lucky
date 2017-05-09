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

  def find_action(method, path)
    @tree.find LuckyWeb::Route.build_route_path(method, path)
  end

  def self.find_action(method, path)
    INSTANCE.find_action(method, path)
  end

  def self.find_action(request)
    INSTANCE.find_action(request.method, request.path)
  end
end
