# Redirects HTTP requests to HTTPS
#
# Uses the `X-Forwarded-Proto` header to determine whether the request was
# made securely. Heroku uses this by default, and so do many other servers.
# If the header is not present, handler will treat the request as insecure.
#
# ### Options
#
# *Redirect Status* - The ForceSSLHandler will use a 308 permanent redirect
# status so the browser knows to request the the secure version every time. You
# Can use a different status code if you prefer.

# *Enabled* - The handler can be enabled/disabled. This is helpful for working
# in a local development environment.
#
# *Strict-Transport-Security* - Settings to configure the ['Strict-Transport-Security' header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)
#
# ```
# # Usually in config/force_ssl_handler.cr
# Lucky::ForceSSLHandler.configure do |settings|
#   settings.redirect_status = 303
#   settings.enabled = false
#   settings.strict_transport_security = {max_age: 1.year, include_subdomains: true}
# end
# ```
class Lucky::ForceSSLHandler
  include HTTP::Handler

  Habitat.create do
    setting redirect_status : Int32 = HTTP::Status::PERMANENT_REDIRECT.value
    setting enabled : Bool
    setting strict_transport_security : NamedTuple(max_age: Time::Span | Time::MonthSpan, include_subdomains: Bool)?
  end

  def call(context)
    if disabled?
      call_next(context)
    elsif secure?(context)
      add_transport_header_if_enabled(context)
      call_next(context)
    else
      redirect_to_secure_version(context)
    end
  end

  private def disabled? : Bool
    !settings.enabled
  end

  private def secure?(context) : Bool
    context.request.headers["X-Forwarded-Proto"]? == "https"
  end

  private def redirect_to_secure_version(context : HTTP::Server::Context)
    context.response.status_code = settings.redirect_status
    context.response.headers["Location"] =
      "#{URI.new("https", context.request.headers["Host"]?)}#{context.request.resource}"
  end

  # Read more about [Strict-Transport-Security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)
  private def add_transport_header_if_enabled(context : HTTP::Server::Context)
    settings.strict_transport_security.try do |header|
      sts_value = String.build do |s|
        max_age = ensure_time_span(header[:max_age])
        s << "max-age=#{max_age.total_seconds.to_i}"
        s << "; includeSubDomains" if header[:include_subdomains]
      end
      context.response.headers["Strict-Transport-Security"] = sts_value
    end
  end

  private def ensure_time_span(span : Time::Span) : Time::Span
    span
  end

  # 1.year returns a Time::MonthSpan. We need to convert it to a Time::Span
  private def ensure_time_span(span : Time::MonthSpan) : Time::Span
    months = span.value
    (months * 30).days
  end
end
