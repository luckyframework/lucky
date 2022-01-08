# :nodoc:
class Lucky::Router
  getter routes = [] of Lucky::Route
  @matcher = LuckyRouter::Matcher(Lucky::Action.class).new

  def add(method : Symbol, path : String, action : Lucky::Action.class) : Nil
    route = Lucky::Route.new(method, path, action)
    @routes << route
    @matcher.add(route.method.to_s, route.path, route.action)
  end

  def find_action(method : Symbol | String, path : String) : LuckyRouter::Match(Lucky::Action.class)?
    @matcher.match method.to_s.downcase, path
  end

  def find_action(request : HTTP::Request) : LuckyRouter::Match(Lucky::Action.class)?
    find_action(request.method, request.path)
  end
end
