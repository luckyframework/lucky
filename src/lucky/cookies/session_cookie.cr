class Lucky::SessionCookie
  Habitat.create do
    setting key : String
  end

  alias Key = String | Symbol
  private property store = {} of String => String
  @changed = false

  def initialize(cookie : Lucky::MaybeCookie = Lucky::NullCookie.new)
    contents = cookie.value || "{}"
    JSON.parse(contents).as_h.each do |key, value|
      @store[key] = value.to_s
    end
  end

  def get(key : Key) : String
    store[key.to_s]
  end

  def get?(key : Key) : String?
    store[key.to_s]?
  end

  def set(key : Key, value : String) : String
    @changed = true
    store[key.to_s] = value
  end

  def changed?
    @changed
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
