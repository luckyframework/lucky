require "../../spec_helper"

include ContextHelper

describe Lucky::SessionStore do
  describe "#transfer" do
    it "stores the session on a cookie" do
      context = build_context
      store = Lucky::SessionStore.new
      store.set(:email, "test@example.com")

      store.transfer(to: context.better_cookies)

      context.better_cookies.to_h.has_key?("_app_session").should be_true

      store_json = { "email" => "test@example.com" }.to_json
      encryptor = Lucky::MessageEncryptor.
        new(Lucky::Server.settings.secret_key_base)
      store_encrypted = encryptor.encrypt(store_json)
      store_encoded = Base64.strict_encode(store_encrypted)
      encoded = context.better_cookies.get("_app_session")
      encrypted = Base64.decode(encoded)
      json = String.new(encryptor.decrypt(encrypted))

      json.should eq(store_json)
    end
  end

  describe "#from" do
    it "retrives and decrypts the session from cookies" do
      json = { "email" => "test@example.com" }.to_json
      encryptor = Lucky::MessageEncryptor.
        new(Lucky::Server.settings.secret_key_base)
      store_encrypted = encryptor.encrypt(json)
      store_encoded = Base64.strict_encode(store_encrypted)
      context = build_context
      context.better_cookies.set("_app_session", store_encoded)

      store = Lucky::SessionStore.from(cookies: context.better_cookies)

      store.get(:email).should eq("test@example.com")
    end
  end
end
