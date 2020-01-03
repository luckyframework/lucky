# :nodoc:
class Lucky::Router
  INSTANCE = new

  getter :routes

  def initialize
    @matcher = LuckyRouter::Matcher(Lucky::Action.class).new
    @routes = [] of Lucky::Route
  end

  def self.add(method, path, action) : Nil
    INSTANCE.add(method, path, action)
  end

  def self.routes : Array(Lucky::Route)
    INSTANCE.routes
  end

  def add(method, path, action) : Nil
    route = Lucky::Route.new(method, path, action)
    @routes << route
    @matcher.add(route.method.to_s, route.path, route.action)
  end

  def find_action(method, path) : LuckyRouter::Match(Lucky::Action.class)?
    @matcher.match method.to_s.downcase, path
  end

  def self.find_action(method, path) : LuckyRouter::Match(Lucky::Action.class)?
    INSTANCE.find_action(method, path)
  end

  def self.find_action(request) : LuckyRouter::Match(Lucky::Action.class)?
    INSTANCE.find_action(request.method, request.path)
  end
end
