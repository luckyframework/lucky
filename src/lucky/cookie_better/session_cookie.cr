class Lucky::SessionCookie
  Habitat.create do
    setting key : String
  end

  alias Key = String | Symbol
  private property store = {} of String => String

  def []=(key : Key, value : String)
    store[key.to_s] = value
  end

  def [](key : Key)
    store[key.to_s]
  end

  def []?(key : Key)
    store[key.to_s]?
  end

  def clear
    self.store = {} of String => String
  end

  def to_h : Hash(String, String)
    store
  end
end
