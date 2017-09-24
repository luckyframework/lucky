class LuckyWeb::Session::Store
  AS_LONG_AS_POSSIBLE = 0

  getter cookies : Cookies::Store

  Habitat.create do
    setting key : String
    setting expires : Int32 = AS_LONG_AS_POSSIBLE
    setting secret : String
    setting store : Symbol = :cookie
  end

  def initialize(@cookies)
  end

  def build : Session::AbstractStore
    CookieStore.build(cookie_store, settings)
  end

  private def cookie_store
    if encrypted_cookie?
      cookies.encrypted
    else
      cookies.signed
    end
  end

  private def encrypted_cookie?
    settings.store == :encrypted_cookie
  end

  private def secret
    settings.secret
  end
end
