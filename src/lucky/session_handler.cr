class Lucky::SessionHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)

    if context.session.changed?
      context.cookies.set(
        Lucky::SessionCookie.settings.key,
        context.session.to_json
      )
    end

    if context.cookies.changed?
      Lucky::BetterCookies::Processors::Encryptor.write(
        cookie_jar: context.cookies,
        to: context.response
      )
    end
  end
end
