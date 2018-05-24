require "base64"
require "yaml"
require "openssl/hmac"

module Lucky
  module Flash
    def self.from_session(flash_content)
      Store.from_session(flash_content)
    end

    # :nodoc:
    class Handler
      include HTTP::Handler

      PARAM_KEY = "_flash"

      def call(context)
        call_next(context)
      ensure
        context.session[PARAM_KEY] = context.flash.to_json
      end
    end

    # Flash store is used to store and access messages in web requests.
    # You can access the methods in the Flash store by calling `flash` in an
    # action or a page.
    #
    # ```
    # # in an action or page
    # flash["success"] = "Your project was created"
    # flash["success"] # => "Your project was created"
    # ```
    #
    # You can set any key you want with `#[]`, but it's safe and clearer to use
    # the `#success`, `#info`, `#danger` shortcuts:
    #
    # ```
    # flash.success = "Your project was created"
    # flash.success # => "Your project was created"
    # ```
    class Store
      @next_key_is_for_now : Bool = false

      forward_missing_to all_messages

      def self.from_session(session : Lucky::Session::AbstractStore) : Store
        json = JSON.parse session.fetch(Lucky::Flash::Handler::PARAM_KEY, "{}")
        new.tap do |flash|
          json.as_h.each do |key, value|
            flash.now[key] = value.to_s
          end
        end
      rescue e : JSON::ParseException
        new
      end

      def initialize
        @now = {} of String => String
        @next = {} of String => String
      end

      private def all_messages
        @next.merge(@now)
      end

      def fetch(key : String)
        @now.fetch(key)
      end

      def fetch(key : Symbol)
        fetch key.to_s
      end

      # :nodoc:
      def fetch(_not_accepted : T) forall T
        {% raise "Flash key must be a Symbol or String, got #{T}" %}
      end

      # Keep all the flash messages for the next request
      #
      # Normally messages from the previous request will be cleared at the end
      # of the current request. If you use `keep_all` all messages will be available
      # to the next request.
      def keep_all
        @now.each do |key, value|
          @next[key] ||= value
        end
      end

      def []?(key : Symbol | String)
        all_messages[key.to_s]?
      end

      # :nodoc:
      def [](_not_accepted : T) forall T
        {% raise "Flash key must be a Symbol or String, got #{T}" %}
      end

      def [](key : Symbol | String)
        all_messages[key.to_s]
      end

      # :nodoc:
      def []?(_not_accepted : T) forall T
        {% raise "Flash key must be a Symbol or String, got #{T}" %}
      end

      def []=(key : Symbol, value : String)
        self[key.to_s] = value
      end

      def []=(key : String, value : String)
        if @next_key_is_for_now
          @now[key] = value
          @next_key_is_for_now = false
        else
          @next[key] = value
        end
      end

      # Store a message for the current request only
      #
      # This is helpful if you want to show a message to the user only in the
      # current request. Usually you do this when you call `render` instead of
      # `redirect`
      #
      # ```
      # # in an action
      # flash.now.danger = "Oops! Form didn't save"
      # ```
      def now : Store
        @next_key_is_for_now = true
        self
      end

      {% for shortcut in [:danger, :info, :success] %}
        # Shortcut for accessing a {{ shortcut.id }} message
        #
        # ```
        # flash.{{ shortcut.id }} # => Returns the message in the "{{ shortcut.id }}" key
        # ```
        def {{ shortcut.id }}
          self.["{{ shortcut.id }}"]
        end

        # Shortcut for setting a {{ shortcut.id }} message
        #
        # ```
        # flash.{{ shortcut.id }} = "My message"
        # ```
        def {{ shortcut.id }}=(message : String)
          self["{{ shortcut.id }}"] = message
        end
      {% end %}

      # :nodoc:
      def to_json
        @next.to_json
      end
    end
  end
end
