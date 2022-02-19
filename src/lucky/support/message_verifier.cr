require "openssl/hmac"
require "crypto/subtle"

module Lucky
  class MessageVerifier
    def initialize(@secret : String, @digest = :sha1)
    end

    def valid_message?(data, digest) : Bool
      data.size > 0 && digest.size > 0 && Crypto::Subtle.constant_time_compare(digest, generate_digest(data))
    end

    def verified(signed_message : String) : String?
      json_data = ::Base64.decode_string(signed_message)
      data, digest = Tuple(String, String).from_json(json_data)

      if valid_message?(data, digest)
        String.new(decode(data))
      end
    rescue argument_error : ArgumentError
      return if argument_error.message =~ %r{invalid base64}
      raise argument_error
    end

    def verify(signed_message) : String
      verified(signed_message) || raise(InvalidSignatureError.new)
    end

    def verify_raw(signed_message : String) : Bytes
      json_data = ::Base64.decode_string(signed_message)
      data, digest = Tuple(String, String).from_json(json_data)

      if valid_message?(data, digest)
        decode(data)
      else
        raise(InvalidSignatureError.new)
      end
    end

    def generate(value : String | Bytes) : String
      data = encode(value)
      encode({data, generate_digest(data)}.to_json)
    end

    private def encode(data) : String
      ::Base64.urlsafe_encode(data)
    end

    private def decode(data) : Bytes
      ::Base64.decode(data)
    end

    private def generate_digest(data) : String
      encode(OpenSSL::HMAC.digest(OpenSSL::Algorithm.parse(@digest.to_s), @secret, data))
    end
  end
end
