class HTTP::Cookie
  def name(value : String)
    self.name = value
    self
  end

  def value(string : String)
    self.value = string
    self
  end

  def path(value : String)
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

  def secure(value : Bool)
    self.secure = value
    self
  end

  def http_only(value : Bool)
    self.http_only = value
    self
  end
end
