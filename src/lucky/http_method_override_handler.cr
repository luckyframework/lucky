class Lucky::HttpMethodOverrideHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    http_method = overridden_http_method(context)

    if http_method && override_allowed?(context, http_method)
      context.request.method = http_method
    end

    call_next(context)
  end

  private def override_allowed?(context : HTTP::Server::Context, http_method : String) : Bool
    (context.request.method == "POST") && ["PATCH", "PUT", "DELETE"].includes?(http_method)
  end

  private def overridden_http_method(context : HTTP::Server::Context) : String?
    context.params.get?(:_method).try(&.upcase)
  rescue Lucky::ParamParsingError
    nil
  end
end
