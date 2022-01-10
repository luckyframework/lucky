# :nodoc:
class Lucky::Router
  getter routes = [] of Tuple(Symbol, String, Lucky::Action.class)
  @matcher = LuckyRouter::Matcher(Lucky::Action.class).new

  def add(method : Symbol, path : String, action : Lucky::Action.class) : Nil
    @routes << {method, path, action}
    @matcher.add(method.to_s, path, action)
  end

  def find_action(method : Symbol | String, path : String) : LuckyRouter::Match(Lucky::Action.class)?
    @matcher.match method.to_s.downcase, path
  end

  def find_action(request : HTTP::Request) : LuckyRouter::Match(Lucky::Action.class)?
    find_action(request.method, request.path)
  end
end
