class Lucky::CookieJar
  alias Key = String | Symbol
  private getter jar = {} of String => String

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
    @jar = {} of String => String
  end
end
