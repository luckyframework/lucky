require "./*"

abstract class LuckyWeb::Action
  getter :context, :route_params

  def initialize(@context : HTTP::Server::Context, @route_params : Hash(String, String))
  end

  abstract def call : LuckyWeb::Response

  include LuckyWeb::ActionDelegates
  include LuckyWeb::ContentTypeHelpers
  include LuckyWeb::Exposeable
  include LuckyWeb::Routeable
  include LuckyWeb::Renderable
  include LuckyWeb::ParamHelpers
  include LuckyWeb::ActionCallbacks
  include LuckyWeb::Redirectable
end
