class Lucky::Router
  alias RouteMatch = LuckyRouter::Match(Lucky::Action.class) | Lucky::FallbackRoute | Nil
  private class_property instance = new

  getter :routes
  getter fallback : Lucky::FallbackRoute?

  def initialize
    @matcher = LuckyRouter::Matcher(Lucky::Action.class).new
    @routes = [] of Lucky::Route
    @fallback = nil
  end

  def self.add(method, path, action) : Nil
    instance.add(method, path, action)
  end

  def self.add_fallback(action) : Lucky::FallbackRoute
    instance.add_fallback(action)
  end

  def self.routes : Array(Lucky::Route)
    instance.routes
  end

  # :nodoc:
  def self.reset! : Nil
    @@instance = new
    nil
  end

  def add(method, path, action) : Nil
    route = Lucky::Route.new(method, path, action)
    @routes << route
    @matcher.add(route.method.to_s, route.path, route.action)
  end

  def add_fallback(action) : Lucky::FallbackRoute
    @fallback = Lucky::FallbackRoute.new(action)
  end

  def find_action(method, path) : RouteMatch
    @matcher.match(method.to_s.downcase, path) || fallback
  end

  def self.find_action(method, path) : RouteMatch
    instance.find_action(method, path)
  end

  def self.find_action(request) : RouteMatch
    instance.find_action(request.method, request.path)
  end
end
