require "../../spec_helper"

describe Lucky::CookieJar do
  it "gets and sets with indifferent access" do
    jar = Lucky::CookieJar.new

    jar.set(:symbol_key, "symbol key")
    jar.set("string_key", "string key")

    jar.get(:symbol_key).value.should eq("symbol key")
    jar.get("symbol_key").value.should eq("symbol key")
    jar.get("string_key").value.should eq("string key")
    jar.get(:string_key).value.should eq("string key")
  end

  describe "#clear" do
    it "sets the jar to an empty hash" do
      jar = Lucky::CookieJar.new
      jar.set(:name, "Edward")

      jar.clear

      jar.get?(:name).value.should be_nil
    end
  end

  describe "#changed?" do
    it "returns true when any cookie is set" do
      jar = Lucky::CookieJar.new

      jar.changed?.should be_false

      jar.set(:city, "Boston")

      jar.changed?.should be_true
    end
  end
end
