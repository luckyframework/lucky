require "../../spec_helper"

describe Lucky::MessageVerifier do
  it "is valid" do
    verifier = Lucky::MessageVerifier.new("supersecretsquirrel", :sha256)
    signed_message = verifier.generate("abc123")
    verifier.verified(signed_message).should eq("abc123")
  end

  it "still works with some more complext data" do
    verifier = Lucky::MessageVerifier.new("mFClXIwWbxfqJwnJ/rXXFK02kO5z8wY2P8mjozsEQDk=", :sha256)
    signed_message = verifier.generate("#{Time.utc(2022, 1, 15, 10, 12).to_unix}:some_special_dude@hotmail.com:b211cbb5-3cc0-475a-9ebe-45f3fd2fe650")
    verifier.verified(signed_message).should eq("1642241520:some_special_dude@hotmail.com:b211cbb5-3cc0-475a-9ebe-45f3fd2fe650")
  end
end
