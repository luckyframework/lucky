require "../../spec_helper"

describe Lucky::MessageEncryptor do
  describe "#encrypt" do
    it "raises a helpful error if the secret_key_base is not a valid key" do
      encryptor = Lucky::MessageEncryptor.new("definately not a valid key")

      expect_raises(Lucky::MessageEncryptor::InvalidSecretKeyBase) do
        encryptor.encrypt("anything")
      end
    end
  end

  describe "#decrypt" do
    it "raises a helpful error if the secret_key_base is not a valid key" do
      encryptor = Lucky::MessageEncryptor.new("definately not a valid key")
      expect_raises(Lucky::MessageEncryptor::InvalidSecretKeyBase) do
        encryptor.decrypt(irrelevant_data)
      end
    end
  end
end

private def irrelevant_data
  data = IO::Memory.new
  data << Base64.strict_encode("irrelevant")
  data.to_slice
end
