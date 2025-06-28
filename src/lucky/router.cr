# :nodoc:
class Lucky::Router
  @matcher = LuckyRouter::Matcher(Lucky::Action.class).new
  @http2_matcher = LuckyRouter::Matcher(Lucky::HTTP2::Action.class).new

  # Array of path, method, and payload
  def list_routes : Array(Tuple(String, String, Lucky::Action.class))
    @matcher.list_routes
  end

  def list_http2_routes : Array(Tuple(String, String, Lucky::HTTP2::Action.class))
    @http2_matcher.list_routes
  end

  def add(method : Symbol, path : String, action : Lucky::Action.class) : Nil
    @matcher.add(method.to_s, path, action)
  end

  def add_http2(method : Symbol, path : String, action : Lucky::HTTP2::Action.class) : Nil
    @http2_matcher.add(method.to_s, path, action)
  end

  def find_action(method : Symbol | String, path : String) : LuckyRouter::Match(Lucky::Action.class)?
    @matcher.match method.to_s.downcase, path
  end

  def find_http2_action(method : Symbol | String, path : String) : LuckyRouter::Match(Lucky::HTTP2::Action.class)?
    @http2_matcher.match method.to_s.downcase, path
  end

  def find_action(request : HTTP::Request) : LuckyRouter::Match(Lucky::Action.class)?
    find_action(request.method, request.path)
  end

  def find_http2_action(request : HT2::Request) : LuckyRouter::Match(Lucky::HTTP2::Action.class)?
    find_http2_action(request.method.to_s, request.uri.to_s)
  end
end

macro http2(method, path, action)
  Lucky.router.add_http2({{method}}, {{path}}, {{action}})
end
