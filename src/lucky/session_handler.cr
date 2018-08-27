class Lucky::SessionHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)

    adapter = Lucky::Adapters::PlainAdapter.new
    adapter.write(cookies: context.better_cookies, to: context.response)

    if context.session.changed?
      context.session.set_session
      context.cookies.write(context.response.headers)
    end
  end
end
