require "./*"

abstract class Lucky::Action
  getter :context, :route_params

  def initialize(@context : HTTP::Server::Context, @route_params : Hash(String, String))
  end

  abstract def call

  include Lucky::ActionDelegates
  include Lucky::RequestTypeHelpers
  include Lucky::Exposable
  include Lucky::Routable
  include Lucky::Renderable
  include Lucky::ParamHelpers
  include Lucky::ActionPipes
  include Lucky::Redirectable
  include Lucky::RedirectableTurbolinksSupport
  include Lucky::VerifyAcceptsFormat

  # Must be defined here instead of in Renderable
  # Otherwise it clashes with ErrorAction#render
  private def render(page_class, **named_args)
    {% raise "'render' in actions has been renamed to 'html'" %}
  end
end
