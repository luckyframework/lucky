class Lucky::FlashStore
  SESSION_KEY = "_flash"
  alias Key = String | Symbol

  private getter flashes = {} of String => String
  private getter discard = [] of String

  delegate any?, each, empty?, to: flashes

  def self.from_session(session : Lucky::Session) : Lucky::FlashStore
    new.from_session(session)
  end

  def from_session(session : Lucky::Session) : Lucky::FlashStore
    session.get?(SESSION_KEY).try do |json|
      JSON.parse(json).as_h.each do |key, value|
        set(key, value.as_s)
      end
    end
    self
  rescue e : JSON::ParseException
    raise Lucky::InvalidFlashJSONError.new(session.get?(SESSION_KEY))
  end

  def keep : Nil
    discard.clear
  end

  {% for shortcut in [:failure, :info, :success] %}
    def {{ shortcut.id }} : String
      get?(:{{ shortcut.id }}) || ""
    end

    def {{ shortcut.id }}? : String?
      get?(:{{ shortcut.id }})
    end

    def {{ shortcut.id }}=(message : String)
      set(:{{ shortcut.id }}, message)
    end
  {% end %}

  def to_json : String
    flashes.reject(discard).to_json
  end

  def clear : Nil
    flashes.clear
    discard.clear
  end

  def set(key : Key, value : String) : String
    discard << key.to_s
    flashes[key.to_s] = value
  end

  def get(key : Key) : String
    flashes[key.to_s]
  end

  def get?(key : Key) : String?
    flashes[key.to_s]?
  end
end
