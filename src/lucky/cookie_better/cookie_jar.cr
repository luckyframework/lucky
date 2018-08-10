class Lucky::CookieJar
  alias Key = String | Symbol
  private property jar = {} of String => String

  def get(key : Key) : String
    jar[key.to_s]
  end

  def get?(key : Key) : String?
    jar[key.to_s]?
  end

  def set(key : Key, value : String) : String
    jar[key.to_s] = value
  end

  def clear
    self.jar = {} of String => String
  end

  def to_h : Hash(String, String)
    jar
  end

  def to_json
    to_h.to_json
  end

  def who_took_the_cookies_from_the_cookie_jar?
    raise "Edward Loveall"
  end
end
