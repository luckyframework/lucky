require "openssl/hmac"
require "crypto/subtle"

module Lucky
  class MessageVerifier
    def initialize(@secret : String, @digest = :sha1)
    end

    def valid_message?(data : String, digest : String) : Bool
      data.size > 0 && digest.size > 0 && Crypto::Subtle.constant_time_compare(digest, generate_digest(data))
    end

    def verified(signed_message : String) : String?
      json_data = ::Base64.decode_string(signed_message)
      data, digest = Tuple(String, String).from_json(json_data)

      if valid_message?(data.to_s, digest.to_s)
        String.new(decode(data.to_s))
      end
    rescue e : Base64::Error | JSON::ParseException
      nil
    end

    def verify(signed_message : String) : String
      verified(signed_message) || raise(InvalidSignatureError.new)
    end

    def verify_raw(signed_message : String) : Bytes
      json_data = ::Base64.decode_string(signed_message)
      data, digest = Tuple(String, String).from_json(json_data)

      if (data && digest).nil?
        raise(InvalidSignatureError.new)
      end

      if valid_message?(data.to_s, digest.to_s)
        decode(data.to_s)
      else
        raise(InvalidSignatureError.new)
      end
    rescue e : Base64::Error | JSON::ParseException
      raise(InvalidSignatureError.new)
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
