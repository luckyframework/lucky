class Lucky::NullCookie
  getter name : Nil = nil
  getter value : Nil = nil
  getter path : Nil = nil
  getter expires : Nil = nil
  getter domain : Nil = nil
  getter secure = false
  getter http_only = false
  getter extension : Nil = nil

  def expired?
    true
  end
end

module Lucky
  alias MaybeCookie = HTTP::Cookie | NullCookie
end
