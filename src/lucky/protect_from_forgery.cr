# Protect from CSRF attacks
#
# This module is automatically included in `BrowserAction` to protect from CSRF
# attacks.
module Lucky::ProtectFromForgery
  ALLOWED_METHODS = %w(GET HEAD OPTIONS TRACE)
  SESSION_KEY     = "X-CSRF-TOKEN"
  PARAM_KEY       = "_csrf"

  macro included
    before protect_from_forgery
  end

  Habitat.create do
    setting allow_forgery_protection : Bool = true
  end

  # :nodoc:
  def self.get_token(context : HTTP::Server::Context) : String
    context.session.get(SESSION_KEY)
  end

  private def protect_from_forgery
    set_session_csrf_token
    if !Lucky::ProtectFromForgery.settings.allow_forgery_protection? || request_does_not_require_protection? || valid_csrf_token?
      continue
    else
      forbid_access_because_of_bad_token
    end
  end

  private def set_session_csrf_token
    session.get?(SESSION_KEY) ||
      session.set(SESSION_KEY, Random::Secure.urlsafe_base64(32))
  end

  private def request_does_not_require_protection?
    ALLOWED_METHODS.includes? request.method
  end

  private def valid_csrf_token? : Bool
    session_token == user_provided_token
  end

  private def session_token : String
    session.get(SESSION_KEY)
  end

  private def user_provided_token : String?
    params.get?(PARAM_KEY) || request.headers[SESSION_KEY]?
  end

  private def forbid_access_because_of_bad_token : Lucky::Response
    head :forbidden
  end
end
