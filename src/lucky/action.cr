require "./*"

abstract class Lucky::Action
  getter context : HTTP::Server::Context
  getter route_params : Hash(String, String)

  def initialize(@context : HTTP::Server::Context, @route_params : Hash(String, String))
    context.params.route_params = @route_params
  end

  # Returns whether the matched route params satisfy the action's declared
  # `Lucky::PathParam` types. Actions without typed route params always
  # return `true`. The `Lucky::RouteHandler` uses this to treat a segment
  # that can't be parsed to its declared type as a non-match.
  def self.valid_path_params?(route_params : Hash(String, String)) : Bool
    true
  end

  abstract def call

  include Lucky::ActionDelegates
  include Lucky::RequestTypeHelpers
  include Lucky::Exposable
  include Lucky::Routable
  include Lucky::Renderable
  include Lucky::ParamHelpers
  include Lucky::ActionPipes
  include Lucky::RequestBodyLimit
  include Lucky::Redirectable
  include Lucky::VerifyAcceptsFormat
end
