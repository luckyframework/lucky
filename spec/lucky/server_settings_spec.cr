require "../spec_helper"

describe Lucky::ServerSettings do
  describe "when the watcher config file is missing" do
    it "raises the helpful guidance message instead of a cryptic YAML error" do
      expect_raises(Exception, /Expected config file for the watcher/) do
        Lucky::ServerSettings.host
      end
    end
  end
end
