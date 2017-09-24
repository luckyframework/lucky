class LuckyWeb::SessionHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)

    if context.session.changed?
      context.session.set_session
      context.cookies.write(context.response.headers)
    end
  end
end
