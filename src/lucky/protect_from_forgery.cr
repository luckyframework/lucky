module Lucky::ProtectFromForgery
  ALLOWED_METHODS = %w(GET HEAD OPTIONS TRACE)
  SESSION_KEY     = "X-CSRF-TOKEN"
  PARAM_KEY       = "_csrf"

  macro included
    before protect_from_forgery
    after set_new_csrf_token
  end

  # :nodoc:
  def self.get_token(context : HTTP::Server::Context) : String
    context.session[SESSION_KEY].to_s
  end

  private def protect_from_forgery
    if request_does_not_require_protection? || valid_csrf_token?
      continue
    else
      forbid_access_because_of_bad_token
    end
  end

  private def set_new_csrf_token
    session[SESSION_KEY] = Random::Secure.urlsafe_base64(32)
    continue
  end

  private def request_does_not_require_protection?
    ALLOWED_METHODS.includes? request.method
  end

  private def valid_csrf_token? : Bool
    session_token == user_provided_token
  end

  private def session_token : String
    session[SESSION_KEY].to_s
  end

  private def user_provided_token : String?
    params.get(PARAM_KEY) || headers[SESSION_KEY]?
  end

  def forbid_access_because_of_bad_token : Lucky::Response
    head Lucky::Action::Status::Forbidden
  end
end
