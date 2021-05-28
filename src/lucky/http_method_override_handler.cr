class Lucky::HttpMethodOverrideHandler
  include HTTP::Handler

  def call(context)
    http_method = overridden_http_method(context)

    if override_allowed?(context, http_method) && http_method
      context.request.method = http_method
    end

    call_next(context)
  end

  private def override_allowed?(context, http_method) : Bool
    (context.request.method == "POST") && ["PATCH", "PUT", "DELETE"].includes?(http_method)
  end

  private def overridden_http_method(context) : String?
    context.params.get?(:_method).try(&.upcase)
  rescue Lucky::ParamParsingError
    nil
  end
end
