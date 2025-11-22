require "./*"

abstract class Lucky::Action
  getter context : HTTP::Server::Context
  getter route_params : Hash(String, String)

  def initialize(@context : HTTP::Server::Context, @route_params : Hash(String, String))
    context.params.route_params = @route_params
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
