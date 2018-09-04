class Lucky::SessionHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)

    Lucky::BetterCookies::Adapters::Encrypted.write(
      cookie_jar: context.better_cookies,
      to: context.response
    )
    Lucky::BetterCookies::Adapters::Encrypted.write(
      cookie_jar: context.better_session,
      to: context.response
    )

    if context.session.changed?
      context.session.set_session
      context.cookies.write(context.response.headers)
    end
  end
end
