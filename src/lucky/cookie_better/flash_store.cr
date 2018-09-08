class Lucky::FlashStore
  SESSION_KEY = "_flash"
  alias Key = String | Symbol
  private getter store = {} of String => String

  delegate each, to: store
  
  def self.from_session(session : Lucky::SessionCookie) : Lucky::FlashStore
    json = session.get?(SESSION_KEY) || "{}"
    new.tap do |flash|
      JSON.parse(json).as_h.each do |key, value|
        flash.set(key.to_s, value.to_s)
      end
    end
  rescue e : JSON::ParseException
    new
  end

  def set(key : Key, value : String) : String
    @store[key.to_s] = value
  end

  def get(key : Key) : String
    @store[key.to_s]
  end

  def get?(key : Key) : String?
    @store[key.to_s]?
  end

  {% for shortcut in [:failure, :info, :success] %}
    def {{ shortcut.id }} : String
      get?(:{{ shortcut.id }}) || ""
    end
    
    def {{ shortcut.id }}=(message : String)
      set(:{{ shortcut.id }}, message)
    end
  {% end %}

  def to_json
    store.to_json
  end
end
