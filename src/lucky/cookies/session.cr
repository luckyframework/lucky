class Lucky::Session
  alias Key = String | Symbol
  private property store = {} of String => String

  delegate to_json, clear, to: store

  Habitat.create do
    setting key : String
  end

  def self.from_cookie_jar(cookie_jar : Lucky::CookieJar) : Lucky::Session
    new.tap do |session|
      cookie_jar.get?(settings.key).try do |contents|
        JSON.parse(contents).as_h.each do |key, value|
          session.set key, value.as_s
        end
      end
    end
  end

  def delete(key : Key) : String?
    store.delete key.to_s
  end

  def set(key : Key, value : String) : String
    store[key.to_s] = value
  end

  def get(key : Key) : String
    get?(key) || raise "No key for '#{key}' in session"
  end

  def get?(key : Key) : String?
    store[key.to_s]?
  end
end
