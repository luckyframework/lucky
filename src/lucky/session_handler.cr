class Lucky::SessionHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    adapter = Lucky::Adapters::PlainAdapter.new
    if context.request.headers["Cookie"]?
      context.better_cookies = adapter.read(
        key: Lucky::SessionConfig.settings.key,
        from: context.request
      )
    end
    
    call_next(context)

    adapter.write(
      key: Lucky::SessionConfig.settings.key,
      cookies: context.better_cookies,
      to: context.response
    )

    if context.session.changed?
      context.session.set_session
      context.cookies.write(context.response.headers)
    end
  end
end
