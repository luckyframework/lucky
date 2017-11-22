require "base64"
require "yaml"
require "openssl/hmac"

module Lucky
  module Flash
    def self.from_session(flash_content)
      Store.from_session(flash_content)
    end

    class Handler
      include HTTP::Handler

      PARAM_KEY = "_flash"

      def call(context)
        call_next(context)
      ensure
        flash = context.flash.not_nil!
        context.session[PARAM_KEY] = flash.to_session
      end
    end

    class Store < Hash(String, String)
      def self.from_session(json)
        flash = new
        values = JSON.parse(json)
        values.each { |k, v| flash[k.to_s] = v.to_s }
        flash
      rescue e : JSON::ParseException
        new
      end

      def initialize
        @read = [] of String
        @now = [] of String
        super
      end

      def fetch(key : String)
        @read << key
        super
      end

      def fetch(key : Symbol)
        fetch key.to_s
      end

      def []=(key : Symbol, value : String)
        self[key.to_s] = value
      end

      def each
        current = @first
        while current
          yield({current.key, current.value})
          @read << current.key
          current = current.fore
        end
        self
      end

      def now(key, value)
        @now << key
        self[key] = value
      end

      def keep(key = nil)
        @read.delete key
        @now.delete key
      end

      def alert
        self["alert"]
      end

      def alert=(message)
        self["alert"] = message
      end

      def notice
        self["notice"]
      end

      def notice=(message)
        self["notice"] = message
      end

      def to_session
        reject { |key, _| @read.includes? key }.reject { |key, _| @now.includes? key }.to_json
      end
    end
  end
end
