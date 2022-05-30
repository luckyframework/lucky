require "../../spec_helper"

describe Lucky::MessageVerifier do
  describe "#verify" do
    it "is valid" do
      verifier = Lucky::MessageVerifier.new("supersecretsquirrel", :sha256)
      signed_message = verifier.generate("abc123")
      verifier.verify(signed_message).should eq("abc123")
    end

    it "returns valid data for new tokens" do
      # Token: "#{48.hours.from_now.to_unix}:#{UUID.random}"
      new_token = "WyJNVFkwTmpBNU1qY3dNanBpWTJabE5tUXpPQzB3TTJFMUxUUXhaamd0WWprek9DMWtNR001Tm1JNE4yWTRPVEU9IiwiRUprZ3ZIUEtxNG9EdVV1azlFZWQ0ZkJCWFlVPSJd"
      verifier = Lucky::MessageVerifier.new(secret_key)
      verifier.verify(new_token).should eq("1646092702:bcfe6d38-03a5-41f8-b938-d0c96b87f891")
    end

    it "still works with some more complext data" do
      verifier = Lucky::MessageVerifier.new(secret_key, :sha256)
      signed_message = verifier.generate("#{Time.utc(2022, 1, 15, 10, 12).to_unix}:some_special_dude@hotmail.com:b211cbb5-3cc0-475a-9ebe-45f3fd2fe650")
      verifier.verify(signed_message).should eq("1642241520:some_special_dude@hotmail.com:b211cbb5-3cc0-475a-9ebe-45f3fd2fe650")
    end

    it "fails with an invalid token" do
      broken_token = "bleepbloop"
      verifier = Lucky::MessageVerifier.new(secret_key)
      expect_raises(Lucky::InvalidSignatureError) do
        verifier.verify(broken_token)
      end
    end
  end

  describe "#verify_raw" do
    it "is valid" do
      verifier = Lucky::MessageVerifier.new("supersecretsquirrel", :sha256)
      signed_message = verifier.generate("abc123")
      String.new(verifier.verify_raw(signed_message)).should eq("abc123")
    end

    it "returns valid data for new tokens" do
      # Token: "#{48.hours.from_now.to_unix}:#{UUID.random}"
      new_token = "WyJNVFkwTmpBNU1qY3dNanBpWTJabE5tUXpPQzB3TTJFMUxUUXhaamd0WWprek9DMWtNR001Tm1JNE4yWTRPVEU9IiwiRUprZ3ZIUEtxNG9EdVV1azlFZWQ0ZkJCWFlVPSJd"
      verifier = Lucky::MessageVerifier.new(secret_key)
      String.new(verifier.verify_raw(new_token)).should eq("1646092702:bcfe6d38-03a5-41f8-b938-d0c96b87f891")
    end

    it "still works with some more complext data" do
      verifier = Lucky::MessageVerifier.new(secret_key, :sha256)
      signed_message = verifier.generate("#{Time.utc(2022, 1, 15, 10, 12).to_unix}:some_special_dude@hotmail.com:b211cbb5-3cc0-475a-9ebe-45f3fd2fe650")
      String.new(verifier.verify_raw(signed_message)).should eq("1642241520:some_special_dude@hotmail.com:b211cbb5-3cc0-475a-9ebe-45f3fd2fe650")
    end

    it "fails with an invalid token" do
      broken_token = "bleepbloop"
      verifier = Lucky::MessageVerifier.new(secret_key)
      expect_raises(Lucky::InvalidSignatureError) do
        verifier.verify_raw(broken_token)
      end
    end
  end
end

private def secret_key : String
  "mFClXIwWbxfqJwnJ/rXXFK02kO5z8wY2P8mjozsEQDk="
end
