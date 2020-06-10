class HTTP::Cookie
  def name(value : String) : HTTP::Cookie
    self.name = value
    self
  end

  def value(string : String) : HTTP::Cookie
    self.value = string
    self
  end

  def path(value : String) : HTTP::Cookie
    self.path = value
    self
  end

  def expires(value : Time) : HTTP::Cookie
    self.expires = value
    self
  end

  def domain(value : String) : HTTP::Cookie
    self.domain = value
    self
  end

  def permanent : HTTP::Cookie
    expires(20.years.from_now)
  end

  def secure(value : Bool) : HTTP::Cookie
    self.secure = value
    self
  end

  def http_only(value : Bool) : HTTP::Cookie
    self.http_only = value
    self
  end

  def samesite(value : HTTP::Cookie::SameSite) : HTTP::Cookie
    self.samesite = value
    self
  end
end
