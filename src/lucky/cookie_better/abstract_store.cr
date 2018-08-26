abstract class Lucky::AbstractStore
  alias Key = String | Symbol
  private property store = {} of String => String

  def []=(key, value)
    {% raise "[]= is gone, please use .set(key, value) instead" %}
  end

  def [](key)
    {% raise "[] is gone, please use .get(key) instead" %}
  end

  def get(key : Key) : String
    store[key.to_s]
  end

  def get?(key : Key) : String?
    store[key.to_s]?
  end

  def set(key : Key, value : String) : String
    store[key.to_s] = value
  end

  def clear
    self.store = {} of String => String
  end

  def to_h : Hash(String, String)
    store
  end
end
