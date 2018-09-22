class Lucky::SessionHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)

    write_session(context)
    write_cookies(context)
    check_cookie_size(context)
  end

  private def write_session(context : HTTP::Server::Context)
    return if !context.session.changed?
    context.cookies.set(
      Lucky::SessionCookie.settings.key,
      context.session.to_json
    )
  end

  private def write_cookies(context : HTTP::Server::Context)
    return if !context.cookies.changed?
    Lucky::BetterCookies::Processors::Encryptor.write(
      cookie_jar: context.cookies,
      to: context.response
    )
  end

  private def check_cookie_size(context : HTTP::Server::Context)
    set_cookie_header = context.response.headers["Set-Cookie"]?
    if set_cookie_header && set_cookie_header.bytesize > Lucky::CookieJar::MAX_COOKIE_SIZE
      raise Lucky::Exceptions::CookieOverflow.new
    end
  end
end
