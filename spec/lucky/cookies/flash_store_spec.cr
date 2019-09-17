require "../../spec_helper"

include ContextHelper

describe Lucky::FlashStore do
  describe ".from_session" do
    it "creates a flash store from the json in a session" do
      context = build_context_with_flash({"some_key" => "some_value"}.to_json)

      flash_store = Lucky::FlashStore.from_session context.session

      flash_store.get("some_key").should eq "some_value"
    end

    it "raises an error when flash JSON is invalid" do
      context = build_context_with_flash("not_valid_json=invalid")
      message = <<-MESSAGE
      The flash messages (stored as JSON) failed to parse in a JSON parser.
      Here's what it tries to parse:

      not_valid_json=invalid
      MESSAGE

      expect_raises(Lucky::InvalidFlashJSON, message) do
        Lucky::FlashStore.from_session context.session
      end
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

  it "has nillable shortcuts" do
    flash_store = Lucky::FlashStore.new

    flash_store.failure?.should be_nil
    flash_store.info?.should be_nil
    flash_store.success?.should be_nil
  end

  describe "#each" do
    it "returns the list of key/value pairs" do
      flash_store = build_flash_store(next: {
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

  describe "#all" do
    it "prefers values from @next over @now" do
      next_hash = {"name" => "Paul"}
      now_hash = {"name" => "Edward"}
      flash_store = build_flash_store(now: now_hash, next: next_hash)

      flash_store.get("name").should eq("Paul")
    end
  end

  describe "#set" do
    it "sets values from symbols and strings" do
      flash_store = build_flash_store

      flash_store.set(:name, "Paul")
      flash_store.set("dungeons", "dragons")

      flash_store.get("name").should eq("Paul")
      flash_store.get("dungeons").should eq("dragons")
    end
  end

  describe "#get" do
    it "retrieves values from both @now and @next" do
      next_hash = {"baker" => "Paul"}
      now_hash = {"cookie theif" => "Edward"}
      flash_store = build_flash_store(now: now_hash, next: next_hash)

      flash_store.get("baker").should eq("Paul")
      flash_store.get("cookie theif").should eq("Edward")
    end

    it "retrieves for both symbols and strings" do
      hash = {"baker" => "Paul", "theif" => "Edward"}
      flash_store = build_flash_store(now: hash)

      flash_store.get("baker").should eq("Paul")
      flash_store.get(:theif).should eq("Edward")
    end
  end

  describe "#to_json" do
    it "returns JSON for just the next requests flash messages" do
      now_hash = {not: :present}
      next_hash = {name: "Paul"}
      flash_store = build_flash_store(now: now_hash, next: next_hash)

      flash_store.to_json.should eq(next_hash.to_json)
    end
  end

  describe "#clear" do
    it "clears out all flash messages" do
      now_hash = {not: :present}
      next_hash = {name: "Paul"}
      flash_store = build_flash_store(now: now_hash, next: next_hash)

      flash_store.get(:name).should eq "Paul"
      flash_store.clear
      flash_store.get?(:name).should eq nil
    end
  end
end

private def build_flash_store(
  now = {} of String => String,
  next next_hash = {} of String => String
)
  session = Lucky::Session.new
  session.set(Lucky::FlashStore::SESSION_KEY, now.to_json)
  Lucky::FlashStore.from_session(session).tap do |flash_store|
    next_hash.each do |key, value|
      flash_store.set(key, value)
    end
  end
end
