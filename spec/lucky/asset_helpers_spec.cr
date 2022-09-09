require "../spec_helper"

module Shared::ComponentWithAsset
  def asset_inside_component
    asset("images/logo.png")
  end

  def dynamic_asset_inside_component(interpolated = "logo")
    dynamic_asset("images/#{interpolated}.png")
  end

  def vite_asset_inside_component
    asset("images/lucky_logo.png")
  end
end

private class TestPage
  include Lucky::AssetHelpers
  include Shared::ComponentWithAsset

  def asset_path
    asset("images/logo.png")
  end

  def strips_prefixed_asset_path
    asset("images/inside-assets-folder.png")
  end

  def dynamic_asset_path(interpolated = "logo")
    dynamic_asset("images/#{interpolated}.png")
  end

  def missing_dynamic_asset_path
    dynamic_asset("woops!.png")
  end

  def asset_path_from_vite
    asset("images/lucky_logo.png")
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

    it "works when used from an included module" do
      TestPage.new.asset_inside_component.should eq "/images/logo-with-hash.png"
    end

    it "strips the prefixed '/assets/ in path" do
      TestPage.new.strips_prefixed_asset_path.should eq "/assets/images/inside-assets-folder.png"
    end

    it "prepends the asset_host configuration option" do
      Lucky::Server.temp_config(asset_host: "https://production.com") do
        TestPage.new.asset_path.should eq "https://production.com/images/logo-with-hash.png"
      end
    end
  end

  describe "dynamic asset helper" do
    it "returns the fingerprinted path" do
      TestPage.new.dynamic_asset_path.should eq "/images/logo-with-hash.png"
    end

    it "works inside included module" do
      TestPage.new.dynamic_asset_inside_component.should eq "/images/logo-with-hash.png"
    end

    it "raises a helpful error" do
      expect_raises Exception, "Missing asset: woops!.png" do
        TestPage.new.missing_dynamic_asset_path
      end
    end

    it "prepends the asset_host configuration option" do
      Lucky::Server.temp_config(asset_host: "https://production.com") do
        TestPage.new.dynamic_asset_path.should eq "https://production.com/images/logo-with-hash.png"
      end
    end
  end

  describe "testing with vite manifest" do
    it "returns the fingerprinted path" do
      Lucky::AssetHelpers.asset("images/lucky_logo.png").should eq "/images/lucky_logo.a54cc67e.png"
    end

    it "works when included in another class" do
      TestPage.new.asset_path_from_vite.should eq "/images/lucky_logo.a54cc67e.png"
    end

    it "works when used from an included module" do
      TestPage.new.vite_asset_inside_component.should eq "/images/lucky_logo.a54cc67e.png"
    end

    it "prepends the asset_host configuration option" do
      Lucky::Server.temp_config(asset_host: "https://production.com") do
        TestPage.new.asset_path_from_vite.should eq "https://production.com/images/lucky_logo.a54cc67e.png"
      end
    end

    it "returns the fingerprinted path" do
      TestPage.new.dynamic_asset_path("lucky_logo").should eq "/images/lucky_logo.a54cc67e.png"
    end

    it "works inside included module" do
      TestPage.new.dynamic_asset_inside_component("lucky_logo").should eq "/images/lucky_logo.a54cc67e.png"
    end

    it "raises a helpful error" do
      expect_raises Exception, "Missing asset: woops!.png" do
        TestPage.new.missing_dynamic_asset_path
      end
    end

    it "prepends the asset_host configuration option" do
      Lucky::Server.temp_config(asset_host: "https://production.com") do
        TestPage.new.dynamic_asset_path("lucky_logo").should eq "https://production.com/images/lucky_logo.a54cc67e.png"
      end
    end
  end
end
