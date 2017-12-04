require "../spec_helper"

private class TestPage
  include Lucky::AssetHelpers

  def asset_path
    asset("images/logo.png")
  end

  def dynamic_asset_path
    interpolated = "logo"
    dynamic_asset("images/#{interpolated}.png")
  end

  def missing_dynamic_asset_path
    dynamic_asset("woops!.png")
  end
end

describe Lucky::AssetHelpers do
  describe "compile time asset helper" do
    it "returns the fingerprinted path" do
      Lucky::AssetHelpers.asset("images/logo.png").should eq "/images/logo-with-hash.png"
    end

    it "works when included in another class" do
      TestPage.new.asset_path.should eq "/images/logo-with-hash.png"
    end
  end

  describe "dynamic asset helper" do
    it "returns the fingerprinted path" do
      TestPage.new.dynamic_asset_path.should eq "/images/logo-with-hash.png"
    end

    it "raises a helpful error" do
      expect_raises Exception, "Missing asset: woops!.png" do
        TestPage.new.missing_dynamic_asset_path
      end
    end
  end
end
