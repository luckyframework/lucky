class Lucky::SessionHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)

    write_session(context)
    write_cookies(context)
    check_cookie_size(context)
  end

  private def write_session(context : HTTP::Server::Context) : Void
    context.cookies.set(
      Lucky::Session.settings.key,
      context.session.to_json
    )
  end

  private def write_cookies(context : HTTP::Server::Context) : Void
    response = context.response

    context.cookies.raw.each do |cookie|
      response.cookies[cookie.name] = cookie
    end

    response.cookies.add_response_headers(response.headers)
  end

  private def check_cookie_size(context : HTTP::Server::Context) : Void
    set_cookie_header = context.response.headers["Set-Cookie"]?
    if set_cookie_header && set_cookie_header.bytesize > Lucky::CookieJar::MAX_COOKIE_SIZE
      raise Lucky::Exceptions::CookieOverflow.new
    end
  end
end
