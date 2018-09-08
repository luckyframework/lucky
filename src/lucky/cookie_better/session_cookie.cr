class Lucky::SessionCookie
  Habitat.create do
    setting key : String
  end

  alias Key = String | Symbol
  private property store = {} of String => String

  def initialize(cookie : HTTP::Cookie? = nil)
    cookie ||= HTTP::Cookie.new("dummy", "{}")
    JSON.parse(cookie.value).as_h.each do |key, value|
      @store[key] = value.to_s
    end
  end

  def set(key : Key, value : String)
    store[key.to_s] = value
  end

  def get(key : Key)
    store[key.to_s]
  end

  def get?(key : Key)
    store[key.to_s]?
  end

  def clear
    self.store = {} of String => String
  end

  def to_h : Hash(String, String)
    store
  end

  def to_json
    to_h.to_json
  end
end
