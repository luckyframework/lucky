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

  Habitat.create do
    setting redirect_status : Int32 = Lucky::Action::Status::PermanentRedirect.value
    setting enabled : Bool = true
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
    context.response.headers["Location"] =
      "https://#{context.request.host}#{context.request.resource}"
  end
end
