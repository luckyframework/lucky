require "./support/**"

# Defines a better cookie store for the request
# The cookies being read are the ones received along with the request,
# the cookies being written will be sent out with the response.
# Reading a cookie does not get the cookie object itself back, just the value it holds.
module Lucky
  class Cookies
    module ChainedStore
      def permanent
        @permanent ||= PermanentStore.new(self)
      end

      def encrypted
        @encrypted ||= EncryptedStore.new(self, @secret)
      end

      def signed
        @signed ||= SignedStore.new(self, @secret)
      end
    end

    # Cookies can typically store 4096 bytes.
    MAX_COOKIE_SIZE = 4096

    class Store
      include Enumerable(String)
      include ChainedStore

      getter cookies
      getter secret : String
      property host : String?
      property secure : Bool = false

      def initialize(@host = nil, @secret = SecureRandom.urlsafe_base64(32), @secure = false)
        @cookies = {} of String => String
        @set_cookies = {} of String => HTTP::Cookie
        @delete_cookies = {} of String => HTTP::Cookie
      end

      # Extracts the cookie from the headers and sets it to
      # ```
      # cookies[cookie.name]
      # ```
      # Returns the hash of cookies
      #
      # ```
      # Cookies::Store.from_headers(headers) #=> {}
      # ```
      def self.from_headers(headers)
        cookies = {} of String => HTTP::Cookie
        if values = headers.get?("Cookie")
          values.each do |header|
            HTTP::Cookie::Parser.parse_cookies(header) do |cookie|
              cookies[cookie.name] = cookie
            end
          end
        end

        if values = headers.get?("Set-Cookie")
          values.each do |header|
            HTTP::Cookie::Parser.parse_cookies(header) do |cookie|
              cookies[cookie.name] = cookie
            end
          end
        end

        cookies
      end

      def self.build(request, secret)
        headers = request.headers
        host = request.host
        secure = (headers["HTTPS"]? == "on")
        new(host, secret, secure).tap do |store|
          store.update(from_headers(headers))
        end
      end

      def update(cookies)
        cookies.each do |name, cookie|
          @cookies[name] = cookie.value
        end
      end

      def each(&block : T -> _)
        @cookies.values.each do |cookie|
          yield cookie
        end
      end

      def each
        @cookies.each_value
      end

      def [](name)
        get(name)
      end

      def get(name)
        @cookies[name]?
      end

      def set(name : String, value : String, path : String = "/",
              expires : Time? = nil, domain : String? = nil,
              secure : Bool = false, http_only : Bool = false,
              extension : String? = nil)
        if @cookies[name]? != value || expires
          @cookies[name] = value
          @set_cookies[name] = HTTP::Cookie.new(name, value, path, expires, domain, secure, http_only, extension)
          @delete_cookies.delete(name) if @delete_cookies.has_key?(name)
        end
      end

      def delete(name : String, path = "/", domain : String? = nil)
        return unless @cookies.has_key?(name)

        value = @cookies.delete(name)
        @delete_cookies[name] = HTTP::Cookie.new(name, "", path, Time.epoch(0), domain)
        value
      end

      def deleted?(name)
        @delete_cookies.has_key?(name)
      end

      def []=(name, value)
        set(name, value)
      end

      def []=(name, cookie : HTTP::Cookie)
        @cookies[name] = cookie.value
        @set_cookies[name] = cookie
      end

      def write(headers)
        cookies = [] of String
        @set_cookies.each { |_, cookie| cookies << cookie.to_set_cookie_header if write_cookie?(cookie) }
        @delete_cookies.each { |_, cookie| cookies << cookie.to_set_cookie_header }
        headers.add("Set-Cookie", cookies)
      end

      def write_cookie?(cookie)
        @secure || !cookie.secure
      end
    end

    class JsonSerializer
      def self.load(value)
        JSON.parse(value)
      end

      def self.dump(value)
        value.to_json
      end
    end

    module SerializedStore
      protected def serialize(value)
        serializer.dump(value)
      end

      protected def deserialize(value)
        serializer.load(value).to_s
      end

      protected def serializer
        JsonSerializer
      end

      protected def digest
        :sha256
      end
    end

    class PermanentStore
      include ChainedStore

      getter store : Store

      def initialize(@store)
      end

      def [](name)
        get(name)
      end

      def get(name)
        @store.get(name)
      end

      def []=(name, value)
        set(name, value)
      end

      def set(name : String, value : String, path : String = "/", domain : String? = nil, secure : Bool = false, http_only : Bool = false, extension : String? = nil)
        cookie = HTTP::Cookie.new(name, value, path, 20.years.from_now, domain, secure, http_only, extension)
        @store[name] = cookie
      end
    end

    class SignedStore
      include ChainedStore

      getter store : Store

      def initialize(@store, secret)
        @verifier = Lucky::MessageVerifier.new(secret)
      end

      def [](name)
        get(name)
      end

      def []=(name, value)
        set(name, value)
      end

      def get(name)
        if value = @store.get(name)
          verify(value)
        end
      end

      def set(name : String, value : String, path : String = "/", expires : Time? = nil, domain : String? = nil, secure : Bool = false, http_only : Bool = false, extension : String? = nil)
        cookie = HTTP::Cookie.new(name, @verifier.generate(value), path, expires, domain, secure, http_only, extension)
        raise Exceptions::CookieOverflow.new if cookie.value.bytesize > MAX_COOKIE_SIZE
        @store[name] = cookie
      end

      private def verify(message)
        @verifier.verify(message)
      rescue e # TODO: This should probably actually raise the exception instead of rescueing from it.
        ""
      end
    end

    class EncryptedStore
      include ChainedStore
      include SerializedStore

      getter store : Store

      def initialize(@store, secret)
        @encryptor = Lucky::MessageEncryptor.new(secret, digest: digest)
      end

      def [](name)
        get(name)
      end

      def []=(name, value)
        set(name, value)
      end

      def get(name)
        if value = @store.get(name)
          verify_and_decrypt(value)
        end
      end

      def set(name : String, value : String, path : String = "/", expires : Time? = nil, domain : String? = nil, secure : Bool = false, http_only : Bool = false, extension : String? = nil)
        cookie = HTTP::Cookie.new(name, @encryptor.encrypt_and_sign(value), path, expires, domain, secure, http_only, extension)
        raise Exceptions::CookieOverflow.new if cookie.value.bytesize > MAX_COOKIE_SIZE
        @store[name] = cookie
      end

      private def verify_and_decrypt(encrypted_message)
        String.new(@encryptor.verify_and_decrypt(encrypted_message))
      rescue e # TODO: This should probably actually raise the exception instead of rescueing from it.
        ""
      end
    end
  end
end
