require "./session/**"

class HTTP::Server::Context
  setter session : LuckyWeb::Session::AbstractStore?
  setter cookies : LuckyWeb::Cookies::Store?
  setter flash : LuckyWeb::Flash::Store?

  def cookies
    @cookies ||= LuckyWeb::Cookies::Store.build(request, LuckyWeb::Server.settings.secret_key_base)
  end

  def session
    @session ||= LuckyWeb::Session::Store.new(cookies).build
  end

  def flash
    @flash ||= LuckyWeb::Flash.from_session(session.fetch(LuckyWeb::Flash::Handler::PARAM_KEY, "{}"))
  end
end
