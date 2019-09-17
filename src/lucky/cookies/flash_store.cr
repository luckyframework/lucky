class Lucky::FlashStore
  SESSION_KEY = "_flash"
  alias Key = String | Symbol

  delegate each, to: all

  @now = {} of String => String
  @next = {} of String => String

  def self.from_session(session : Lucky::Session) : Lucky::FlashStore
    new.from_session(session)
  end

  def from_session(session : Lucky::Session) : Lucky::FlashStore
    session.get?(SESSION_KEY).try do |json|
      JSON.parse(json).as_h.each do |key, value|
        @now[key.to_s] = value.to_s
      end
    end
    self
  rescue e : JSON::ParseException
    raise Lucky::InvalidFlashJSON.new(session.get?(SESSION_KEY))
  end

  private def all : Hash(String, String)
    @now.merge(@next)
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
    @next.to_json
  end

  def clear : Nil
    @now.clear
    @next.clear
  end

  def set(key : Key, value : String) : String
    @next[key.to_s] = value
  end

  def get(key : Key) : String
    all[key.to_s]
  end

  def get?(key : Key) : String?
    all[key.to_s]?
  end
end
