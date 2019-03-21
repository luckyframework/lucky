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
# ```
# # Usually in config/force_ssl_handler.cr
# Lucky::ForceSSLHandler.configure do |settings|
#   settings.redirect_status = 303
#   settings.enabled = false
# end
# ```
class Lucky::ForceSSLHandler
  include HTTP::Handler
  alias Hsts = NamedTuple(max_age: Time::Span, include_subdomains: Bool)

  Habitat.create do
    setting redirect_status : Int32 = Lucky::Action::Status::PermanentRedirect.value
    setting enabled : Bool = true
    setting hsts : Hsts? = {max_age: 365.days, include_subdomains: true}
  end

  def call(context)
    if secure?(context) || disabled?
      call_next(context)
    else
      redirect_to_secure_version(context)
    end
  end

  private def disabled? : Bool
    !settings.enabled
  end

  private def secure?(context) : Bool
    !!(context.request.headers["X-Forwarded-Proto"]? =~ /https/i)
  end

  private def redirect_to_secure_version(context : HTTP::Server::Context)
    context.response.status_code = settings.redirect_status
    add_hsts_if_enabled(context)
    context.response.headers["Location"] =
      "https://#{context.request.host}#{context.request.resource}"
  end

  # Read more about [HSTS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)
  private def add_hsts_if_enabled(context : HTTP::Server::Context)
    sts_value = settings.hsts.try do |hsts|
      String.build do |s|
        s << "max-age=#{hsts[:max_age].total_seconds.to_i}"
        s << "; includeSubDomains" if hsts[:include_subdomains]
      end
    end
    context.response.headers["Strict-Transport-Security"] = sts_value if sts_value
  end
end
