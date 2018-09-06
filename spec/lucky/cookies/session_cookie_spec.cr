require "../../spec_helper"

describe Lucky::SessionCookie do
  it "gets and sets with indifferent access" do
    store = Lucky::SessionCookie.new

    store[:symbol_key] = "symbol value"
    store["string_key"] = "string key"

    store[:symbol_key].should eq "symbol value"
    store["symbol_key"].should eq "symbol value"
    store["string_key"].should eq "string key"
    store[:string_key].should eq "string key"
  end

  describe "#clear" do
    it "sets the store to an empty hash" do
      store = Lucky::SessionCookie.new
      store[:name] = "Edward"

      store.clear

      store[:name]?.should be_nil
    end
  end
end
