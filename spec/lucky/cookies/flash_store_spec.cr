require "../../spec_helper"

describe Lucky::FlashStore do
  describe ".from_session" do
    it "creates a flash store from the json in a session" do
      flash_store = Lucky::FlashStore.from_session(build_session({"some_key" => "some_value"}))

      flash_store.get("some_key").should eq "some_value"
    end

    it "raises an error when flash JSON is invalid" do
      message = <<-MESSAGE
      The flash messages (stored as JSON) failed to parse in a JSON parser.
      Here's what it tries to parse:

      not_valid_json=invalid
      MESSAGE

      expect_raises(Lucky::InvalidFlashJSONError, message) do
        Lucky::FlashStore.from_session(build_invalid_session)
      end
    end

    it "does not persist values from session into the next request" do
      flash_store = Lucky::FlashStore.from_session(build_session({"some_key" => "some_value"}))

      next_flash(flash_store).should be_empty
    end
  end

  context "shortcuts" do
    it "has failure" do
      flash_store = Lucky::FlashStore.new

      flash_store.failure?.should be_nil
      flash_store.failure = "Failure"
      flash_store.failure.should eq("Failure")
      flash_store.failure?.should eq("Failure")
      flash_store.get(:failure).should eq("Failure")
    end

    it "has info" do
      flash_store = Lucky::FlashStore.new

      flash_store.info?.should be_nil
      flash_store.info = "Info"
      flash_store.info.should eq("Info")
      flash_store.info?.should eq("Info")
      flash_store.get(:info).should eq("Info")
    end

    it "has success" do
      flash_store = Lucky::FlashStore.new

      flash_store.success?.should be_nil
      flash_store.success = "Success"
      flash_store.success.should eq("Success")
      flash_store.success?.should eq("Success")
      flash_store.get(:success).should eq("Success")
    end
  end

  describe "#keep" do
    it "carries messages over set from session and set during current request" do
      flash_store = build_flash_store({"name" => "Paul"})
      flash_store.set(:info, "Success")

      flash_store.keep.should be_nil
      next_flash = next_flash(flash_store)

      next_flash["name"]?.should eq("Paul")
      next_flash["info"]?.should eq("Success")
    end
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

  describe "#any?" do
    it "returns true if there are key/value pairs" do
      flash_store = build_flash_store({"some_key" => "some_value"})

      # ameba:disable Performance/AnyInsteadOfEmpty
      flash_store.any?.should be_true
    end

    it "returns false if there are no key/value pairs" do
      flash_store = build_flash_store

      # ameba:disable Performance/AnyInsteadOfEmpty
      flash_store.any?.should be_false
    end
  end

  describe "#empty?" do
    it "returns false if there are key/value pairs" do
      flash_store = build_flash_store({"some_key" => "some_value"})

      flash_store.empty?.should be_false
    end

    it "returns true if there are no key/value pairs" do
      flash_store = build_flash_store

      flash_store.empty?.should be_true
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

    it "overwrites exsiting values" do
      flash_store = build_flash_store({"name" => "Paul"})

      flash_store.set(:name, "Pauline")

      flash_store.get(:name).should eq("Pauline")
    end

    it "is not persisted into the next request" do
      flash_store = build_flash_store

      flash_store.set(:success, "Message saved again!")

      next_flash(flash_store).should be_empty
    end
  end

  describe "#get" do
    it "retrieves values from session and set during current request" do
      flash_store = build_flash_store({"cookie thief" => "Edward"})
      flash_store.set(:baker, "Paul")

      flash_store.get("baker").should eq("Paul")
      flash_store.get("cookie thief").should eq("Edward")
    end

    it "retrieves for both symbols and strings" do
      flash_store = build_flash_store({"baker" => "Paul"})

      flash_store.get("baker").should eq("Paul")
      flash_store.get(:baker).should eq("Paul")
    end

    it "works for kept messages" do
      flash_store = build_flash_store
      flash_store.set("baker", "Paul")
      flash_store.keep

      flash_store.get(:baker).should eq("Paul")
      next_flash(flash_store)["baker"]?.should eq("Paul")
    end
  end

  describe "#to_json" do
    it "returns JSON for kept flash messages" do
      flash_store = build_flash_store
      flash_store.set(:next, "should carry over")
      flash_store.keep

      result = flash_store.to_json

      result.should eq({next: "should carry over"}.to_json)
    end
  end

  describe "#clear" do
    it "clears out all flash messages" do
      flash_store = build_flash_store
      flash_store.set(:name, "Paul")

      flash_store.clear

      flash_store.get?(:name).should be_nil
      next_flash(flash_store).should be_empty
    end
  end
end

private def build_flash_store(session_values = {} of String => String)
  Lucky::FlashStore.from_session(build_session(session_values))
end

private def build_session(values = {} of String => String)
  Lucky::Session.new.tap(&.set(Lucky::FlashStore::SESSION_KEY, values.to_json))
end

private def build_invalid_session
  Lucky::Session.new.tap(&.set(Lucky::FlashStore::SESSION_KEY, "not_valid_json=invalid"))
end

private def next_flash(flash_store : Lucky::FlashStore) : Hash(String, JSON::Any)
  JSON.parse(flash_store.to_json).as_h
end
