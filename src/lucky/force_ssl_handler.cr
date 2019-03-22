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

# *HSTS* - Settings to configure HSTS header with max-age and includeSubDomains
#
# ```
# # Usually in config/force_ssl_handler.cr
# Lucky::ForceSSLHandler.configure do |settings|
#   settings.redirect_status = 303
#   settings.enabled = false
#   settings.hsts = {max_age: 18.weeks, include_subdomains: false}
# end
# ```
class Lucky::ForceSSLHandler
  include HTTP::Handler
  alias Hsts = NamedTuple(max_age: Time::Span, include_subdomains: Bool)

  Habitat.create do
    setting redirect_status : Int32 = Lucky::Action::Status::PermanentRedirect.value
    setting enabled : Bool
    setting hsts : Hsts
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
    settings.hsts.try do |hsts|
      sts_value = String.build do |s|
        s << "max-age=#{hsts[:max_age].total_seconds.to_i}"
        s << "; includeSubDomains" if hsts[:include_subdomains]
      end
      context.response.headers["Strict-Transport-Security"] = sts_value
    end
  end
end
