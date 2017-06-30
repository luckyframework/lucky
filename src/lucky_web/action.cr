require "./*"

abstract class LuckyWeb::Action
  getter :context, :route_params

  def initialize(@context : HTTP::Server::Context, @route_params : Hash(String, String))
  end

  abstract def call : LuckyWeb::Response

  EXPOSURES = [] of Symbol

  macro inherited
    include LuckyWeb::Routeable
    include LuckyWeb::Renderable
    include LuckyWeb::ParamHelpers
  end

  def redirect(to path, status = 302)
    context.response.headers.add "Location", path
    context.response.status_code = status
    LuckyWeb::Response.new(context, "", "")
  end
end
