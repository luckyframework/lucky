require "../../spec_helper"
require "../../../src/lucky/server"
require "../../../src/lucky/asset_builder/mix"
require "../../../src/lucky/asset_builder/vite"

describe "Lucky::Server asset build system integration" do
  it "defaults to Mix builder" do
    Lucky::Server.settings.asset_build_system.should be_a(Lucky::AssetBuilder::Mix)
  end
  
  it "can be configured to use Vite" do
    Lucky::Server.temp_config(asset_build_system: Lucky::AssetBuilder::Vite.new) do
      Lucky::Server.settings.asset_build_system.should be_a(Lucky::AssetBuilder::Vite)
    end
  end
  
  it "can use custom manifest paths" do
    custom_builder = Lucky::AssetBuilder::Mix.new("/custom/manifest.json")
    Lucky::Server.temp_config(asset_build_system: custom_builder) do
      Lucky::Server.settings.asset_build_system.manifest_path.should eq("/custom/manifest.json")
    end
  end
end