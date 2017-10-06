require "./*"

abstract class LuckyWeb::Action
  getter :context, :route_params

  delegate cookies, session, to: context

  def initialize(@context : HTTP::Server::Context, @route_params : Hash(String, String))
  end

  abstract def call : LuckyWeb::Response

  include LuckyWeb::Exposeable
  include LuckyWeb::Routeable
  include LuckyWeb::Renderable
  include LuckyWeb::ParamHelpers
  include LuckyWeb::ActionCallbacks

  def redirect(to route : LuckyWeb::RouteHelper, status = 302)
    redirect to: route.path, status: status
  end

  def redirect(to action : LuckyWeb::Action.class, status = 302)
    redirect to: action.route, status: status
  end

  def redirect(to path : String, status = 302)
    context.response.headers.add "Location", path
    context.response.status_code = status
    LuckyWeb::Response.new(context, "", "")
  end
end
