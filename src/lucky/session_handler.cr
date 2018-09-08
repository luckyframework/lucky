class Lucky::SessionHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)

    context.better_cookies.set(Lucky::SessionCookie.settings.key, context.better_session.to_json)
    Lucky::BetterCookies::Processors::Encryptor.write(
      cookie_jar: context.better_cookies,
      to: context.response
    )

    if context.session.changed?
      context.session.set_session
      context.cookies.write(context.response.headers)
    end
  end
end
