require "../../spec_helper"
require "json"

include ContextHelper

module Lucky
  describe Flash::Store do
    describe ".from_session" do
      it "creates a flash store from the json in a session" do
        context = build_context_with_flash({"some_key" => "some_value"}.to_json)

        flash_store = Lucky::Flash::Store.from_session context.session

        flash_store["some_key"].should eq "some_value"
      end

      it "returns an empty flash store if json is invalid" do
        context = build_context_with_flash("not_valid_json=invalid")

        flash_store = Lucky::Flash::Store.from_session context.session

        flash_store["some_key"]?.should be_nil
      end
    end

    describe "#fetch" do
      it "returns the value" do
        flash_store = build_flash_store({"some_key" => "some_value"})

        flash_store.fetch("some_key").should eq "some_value"
      end

      it "supports symbols" do
        flash_store = build_flash_store({"some_key" => "some_value"})

        flash_store.fetch(:some_key).should eq "some_value"
      end
    end

    it "has shortcuts" do
      flash_store = Flash::Store.new
      flash_store.info = "Info"
      flash_store.info.should eq("Info")
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

    describe "#now" do
      it "sets the flash message for the current request" do
        flash_store = Flash::Store.new

        flash_store.now["some_key"] = "some_value"

        flash_store["some_key"].should eq("some_value")
      end
    end

    describe "#to_json" do
      it "returns JSON for just the next requests flash messages" do
        flash_store = Flash::Store.new
        flash_store[:next] = "next"
        flash_store.now[:now] = "now"

        expected_json = {next: "next"}.to_json
        flash_store.to_json.should eq(expected_json)
      end
    end

    describe "#keep_all" do
      it "makes all flashes messages available to the next request" do
        flash_store = Flash::Store.new
        flash_store[:next] = "next"
        flash_store.now[:now] = "now"

        flash_store.keep_all

        expected_json = {next: "next", now: "now"}.to_json
        flash_store.to_json.should eq(expected_json)
      end

      it "does not overwrite messages" do
        flash_store = Flash::Store.new
        flash_store[:original] = "original"
        flash_store.now[:original] = "new"

        flash_store.keep_all

        expected_json = {original: "original"}.to_json
        flash_store.to_json.should eq(expected_json)
      end
    end

    describe "accessors and setters" do
      it "flashes are not current request" do
        flash_store = Flash::Store.new

        flash_store[:message_for_next_request] = "Hello"

        flash_store[:message_for_next_request].should eq("Hello")
      end

      it "supports [] with String" do
        flash_store = build_flash_store({"some_key" => "some_value"})

        flash_store["some_key"].should eq "some_value"
      end

      it "supports [] with Symbol" do
        flash_store = build_flash_store({"some_key" => "some_value"})

        flash_store[:some_key].should eq "some_value"
      end

      it "supports []= with String" do
        flash_store = Lucky::Flash::Store.new
        flash_store["some_key"] = "some_value"

        flash_store["some_key"].should eq "some_value"
      end

      it "supports []= with Symbol" do
        flash_store = Lucky::Flash::Store.new
        flash_store[:some_key] = "some_value"

        flash_store[:some_key].should eq "some_value"
      end

      it "supports []= with Symbol but reading with String" do
        flash_store = Lucky::Flash::Store.new
        flash_store[:some_key] = "some_value"

        flash_store["some_key"].should eq "some_value"
      end
    end
  end
end

private def build_flash_store(flash : Hash(String, String))
  Lucky::Flash::Store.new.tap do |flash_store|
    flash.each do |key, value|
      flash_store.now[key] = value
    end
  end
end
