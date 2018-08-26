require "../../spec_helper"

class AbstractStore < Lucky::AbstractStore
end

describe Lucky::AbstractStore do
  it "gets and sets with indifferent access" do
    store = AbstractStore.new

    store.set :symbol_key, "symbol value"
    store.set "string_key", "string key"

    store.get(:symbol_key).should eq "symbol value"
    store.get("symbol_key").should eq "symbol value"
    store.get("string_key").should eq "string key"
    store.get(:string_key).should eq "string key"
  end

  describe "#clear" do
    it "sets the store to an empty hash" do
      store = AbstractStore.new
      store.set :name, "Edward"

      store.clear

      store.get?(:name).should be_nil
    end
  end
end
