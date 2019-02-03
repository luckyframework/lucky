require "../../spec_helper"

describe Lucky::Session do
  it "gets and sets with indifferent access" do
    store = Lucky::Session.new

    store.set(:symbol_key, "symbol key")
    store.set("string_key", "string key")

    store.get(:symbol_key).should eq("symbol key")
    store.get("symbol_key").should eq("symbol key")
    store.get("string_key").should eq("string key")
    store.get(:string_key).should eq("string key")
  end

  describe "#delete" do
    it "removes the key and value from the session" do
      store = Lucky::Session.new
      store.set(:best_number, "over 9000")

      store.delete(:best_number)

      store.get?(:best_number).should be_nil
    end
  end

  describe "#clear" do
    it "sets the store to an empty hash" do
      store = Lucky::Session.new
      store.set(:name, "Edward")

      store.clear

      store.get?(:name).should be_nil
    end
  end
end
