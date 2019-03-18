class Lucky::RouteNotFoundHandler
  include HTTP::Handler
  class_property fallback_action : Lucky::Action.class | Nil

  def call(context)
    if has_fallback?(context)
      fallback_action.new(context, {} of String => String).perform_action
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end

  private def has_fallback?(context)
    @@fallback_action && context.request.method.upcase == "GET"
  end

  private def fallback_action
    Lucky::RouteNotFoundHandler.fallback_action.not_nil!
  end
end
