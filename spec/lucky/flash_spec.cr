require "../../spec_helper"
require "json"

module Lucky
  describe Flash::Store do
    describe ".from_session" do
      it "creates a flash store from json" do
        flashes = {"some_key" => "some_value"}
        json = flashes.to_json
        flash_store = Flash::Store.from_session json

        flash_store.has_key?("some_key").should be_true
        flash_store["some_key"].should eq "some_value"
      end

      it "returns an empty flash store if json is invalid" do
        json = "some_key=some_value"
        flash_store = Flash::Store.from_session json

        flash_store.has_key?("some_key").should be_false
      end
    end

    describe "#fetch" do
      it "returns the value" do
        flashes = {"some_key" => "some_value"}
        json = flashes.to_json
        flash_store = Flash::Store.from_session json

        flash_store.fetch("some_key").should eq "some_value"
      end

      it "supports symbols" do
        flashes = {"some_key" => "some_value"}
        json = flashes.to_json
        flash_store = Flash::Store.from_session json

        flash_store.fetch(:some_key).should eq "some_value"
      end

      it "marks the value as read" do
        flashes = {"some_key" => "some_value"}
        json = flashes.to_json
        flash_store = Flash::Store.from_session json
        flash_store.fetch("some_key")
        flash_store = Flash::Store.from_session flash_store.to_session

        flash_store.has_key?("some_key").should be_false
      end
    end

    describe "#each" do
      it "returns the list of key/value pairs" do
        flashes = {"some_key" => "some_value", "other_key" => "other_value"}
        json = flashes.to_json
        flash_store = Flash::Store.from_session json
        test = Hash(String, String).new
        flash_store.each { |k, v| test[k] = v }
        test.size.should eq 2
      end

      it "marks the keys as read" do
        flashes = {"some_key" => "some_value", "other_key" => "other_value"}
        json = flashes.to_json
        flash_store = Flash::Store.from_session json
        test = Hash(String, String).new
        flash_store.each { |k, v| test[k] = v }
        flash_store = Flash::Store.from_session flash_store.to_session

        flash_store.has_key?("some_key").should be_false
      end
    end

    describe "#now" do
      it "does not keep key even if never read" do
        flash_store = Flash::Store.new
        flash_store.now("some_key", "some_value")
        flash_store = Flash::Store.from_session flash_store.to_session
        flash_store.has_key?("some_key").should be_false
      end
    end

    describe "#keep" do
      it "keeps the key after being read" do
        flashes = {"some_key" => "some_value"}
        json = flashes.to_json
        flash_store = Flash::Store.from_session json
        flash_store.fetch("some_key")
        flash_store.keep("some_key")
        flash_store = Flash::Store.from_session flash_store.to_session

        flash_store.has_key?("some_key").should be_true
      end
    end

    describe "<< Hash" do
      it "supports [] with String" do
        flashes = {"some_key" => "some_value"}
        json = flashes.to_json
        flash_store = Flash::Store.from_session json

        flash_store["some_key"].should eq "some_value"
      end

      it "supports [] with Symbol" do
        flashes = {"some_key" => "some_value"}
        json = flashes.to_json
        flash_store = Flash::Store.from_session json

        flash_store[:some_key].should eq "some_value"
      end

      it "supports []= with String" do
        flash_store = Flash::Store.new
        flash_store["some_key"] = "some_value"

        flash_store["some_key"].should eq "some_value"
      end

      it "supports []= with Symbol" do
        flash_store = Flash::Store.new
        flash_store[:some_key] = "some_value"

        flash_store[:some_key].should eq "some_value"
      end

      it "supports []= with Symbol but reading with String" do
        flash_store = Flash::Store.new
        flash_store[:some_key] = "some_value"

        flash_store["some_key"].should eq "some_value"
      end
    end
  end
end
