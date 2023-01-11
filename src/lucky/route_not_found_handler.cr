# This HTTP::Handler takes in the current `context`,
# then checks to see if a `fallback_action` has been defined to render that action first.
# If no fallback has been defined, then it will raise a `Lucky::RouteNotFoundError` exception.
#
# This handler should be used after the `Lucky::RouteHandler`.
#
# See `Lucky::Routable.fallback` for implementing the `fallback_action`.
class Lucky::RouteNotFoundHandler
  include HTTP::Handler
  class_property fallback_action : Lucky::Action.class | Nil

  def call(context)
    if has_fallback?(context)
      Lucky::Log.dexter.debug { {handled_by_fallback: fallback_action.name.to_s} }
      fallback_action.new(context, {} of String => String).perform_action
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end

  private def has_fallback?(context) : Bool
    !!@@fallback_action && context.request.method.upcase == "GET"
  end

  private def fallback_action : Lucky::Action.class
    Lucky::RouteNotFoundHandler.fallback_action.as(Lucky::Action.class)
  end
end
