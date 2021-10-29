require "../../spec_helper"

describe Lucky::MessageVerifier do
  it "is valid" do
    verifier = Lucky::MessageVerifier.new("supersecretsquirrel", :sha256)
    signed_message = verifier.generate("abc123")
    verifier.verified(signed_message).should eq("abc123")
  end
end
