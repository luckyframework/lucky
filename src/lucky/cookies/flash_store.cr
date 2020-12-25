module Lucky
  module FlashInteractions
    alias Key = String | Symbol

    abstract def set(key : Key, value : String) : String
    abstract def get(key : Key) : String
    abstract def get?(key : Key) : String?

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
  end

  class FlashStore
    include FlashInteractions
    SESSION_KEY = "_flash"

    private getter flashes = {} of String => String
    private getter discard = Set(String).new

    delegate any?, each, empty?, to: flashes

    def self.from_session(session : Lucky::Session) : Lucky::FlashStore
      new.from_session(session)
    end

    def from_session(session : Lucky::Session) : Lucky::FlashStore
      session.get?(SESSION_KEY).try do |json|
        JSON.parse(json).as_h.each do |key, value|
          flashes[key.to_s] = value.to_s
          discard << key.to_s
        end
      end
      self
    rescue e : JSON::ParseException
      raise Lucky::InvalidFlashJSONError.new(session.get?(SESSION_KEY))
    end

    def set(key : Key, value : String) : String
      discard.delete(key.to_s)
      flashes[key.to_s] = value
    end

    def get(key : Key) : String
      flashes[key.to_s]
    end

    def get?(key : Key) : String?
      flashes[key.to_s]?
    end

    def keep : Nil
      discard.clear
    end

    def to_json : String
      flashes.reject(discard.to_a).to_json
    end

    def clear : Nil
      flashes.clear
      discard.clear
    end

    def discard(key : Key) : Nil
      discard << key.to_s
    end

    def now : FlashNow
      FlashNow.new(self)
    end

    struct FlashNow
      include FlashInteractions

      private getter flash_store : FlashStore

      def initialize(@flash_store)
      end

      def set(key : Key, value : String) : String
        flash_store.set(key, value)
        flash_store.discard(key)
        value
      end

      def get(key : Key) : String
        flash_store.get(key)
      end

      def get?(key : Key) : String?
        flash_store.get?(key)
      end
    end
  end
end
