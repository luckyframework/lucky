class Lucky::SessionHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)

    write_session(context)
    write_cookies(context)
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

    response.headers.delete("Set-Cookie")
    response.cookies.each do |cookie|
      set_cookie_header = cookie.to_set_cookie_header
      if set_cookie_header && set_cookie_header.bytesize > Lucky::CookieJar::MAX_COOKIE_SIZE
        raise Lucky::Exceptions::CookieOverflow.new("size of '#{cookie.name}' cookie is too big")
      end
      response.headers.add("Set-Cookie", cookie.to_set_cookie_header)
    end
  end
end
