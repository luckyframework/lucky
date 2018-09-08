require "../../../spec_helper"

include ContextHelper

describe Lucky::FlashStore do
  describe ".from_session" do
    it "creates a flash store from the json in a session" do
      context = build_context_with_flash({"some_key" => "some_value"}.to_json)

      flash_store = Lucky::FlashStore.from_session context.better_session

      flash_store.get("some_key").should eq "some_value"
    end

    it "returns an empty flash store if json is invalid" do
      context = build_context_with_flash("not_valid_json=invalid")

      flash_store = Lucky::FlashStore.from_session context.better_session

      flash_store.get?("some_key").should be_nil
    end
  end

  it "has shortcuts" do
    flash_store = Lucky::FlashStore.new

    flash_store.failure = "Failure"
    flash_store.info = "Info"
    flash_store.success = "Success"

    flash_store.failure.should eq("Failure")
    flash_store.info.should eq("Info")
    flash_store.success.should eq("Success")
  end

  describe "#each" do
    it "returns the list of key/value pairs" do
      flash_store = build_flash_store({
        "some_key"  => "some_value",
        "other_key" => "other_value",
      })

      test = Hash(String, String).new
      flash_store.each { |k, v| test[k] = v }
      test.size.should eq 2
      test["some_key"].should eq "some_value"
      test["other_key"].should eq "other_value"
    end
  end

  describe "#to_json" do
    it "returns JSON for just the next requests flash messages" do
      flash_store = Lucky::FlashStore.new
      flash_store.set(:name, "Paul")
      expected_json = { name: "Paul" }.to_json

      flash_store.to_json.should eq(expected_json)
    end
  end
end

private def build_flash_store(flash : Hash(String, String))
  Lucky::FlashStore.new.tap do |flash_store|
    flash.each do |key, value|
      flash_store.set(key, value)
    end
  end
end
