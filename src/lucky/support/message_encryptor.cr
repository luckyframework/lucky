require "json"
require "openssl/cipher"
require "./message_verifier"

module Lucky
  class MessageEncryptor
    getter verifier : MessageVerifier

    def initialize(@secret : String, @cipher_algorithm = "aes-256-cbc", @digest = :sha1)
      @verifier = MessageVerifier.new(@secret, digest: @digest)
      @block_size = 16
    end

    # Encrypt and sign a message. We need to sign the message in order to avoid
    # padding attacks. Reference: http://www.limited-entropy.com/padding-oracle-attacks.
    def encrypt_and_sign(value : Slice(UInt8)) : String
      verifier.generate(encrypt(value))
    end

    def encrypt_and_sign(value : String) : String
      encrypt_and_sign(value.to_slice)
    end

    # Verify and Decrypt a message. We need to verify the message in order to
    # avoid padding attacks. Reference: http://www.limited-entropy.com/padding-oracle-attacks.
    def verify_and_decrypt(value : String) : Bytes
      decrypt(verifier.verify_raw(value))
    end

    def encrypt(value)
      cipher = OpenSSL::Cipher.new(@cipher_algorithm)
      cipher.encrypt
      cipher.key = @secret

      # Rely on OpenSSL for the initialization vector
      iv = cipher.random_iv

      encrypted_data = IO::Memory.new
      encrypted_data.write(cipher.update(value))
      encrypted_data.write(cipher.final)
      encrypted_data.write(iv)

      encrypted_data.to_slice
    end

    def decrypt(value : Bytes)
      cipher = OpenSSL::Cipher.new(@cipher_algorithm)
      data = value[0, value.size - @block_size]
      iv = value[value.size - @block_size, @block_size]

      cipher.decrypt
      cipher.key = @secret
      cipher.iv = iv

      decrypted_data = IO::Memory.new
      decrypted_data.write cipher.update(data)
      decrypted_data.write cipher.final
      decrypted_data.to_slice
    end
  end
end
