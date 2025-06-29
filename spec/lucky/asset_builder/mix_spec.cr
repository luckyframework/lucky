require "../../spec_helper"
require "../../../src/lucky/asset_builder/mix"

describe Lucky::AssetBuilder::Mix do
  describe "#manifest_path" do
    it "defaults to ./public/mix-manifest.json" do
      builder = Lucky::AssetBuilder::Mix.new
      builder.manifest_path.should eq("./public/mix-manifest.json")
    end
    
    it "accepts custom path" do
      builder = Lucky::AssetBuilder::Mix.new("/custom/path.json")
      builder.manifest_path.should eq("/custom/path.json")
    end
  end
  
  describe "#parse_manifest" do
    it "parses Mix manifest format correctly" do
      manifest_json = <<-JSON
      {
        "/js/app.js": "/js/app.12345.js",
        "/css/app.css": "/css/app.67890.css",
        "/images/logo.png": "/images/logo.abcde.png"
      }
      JSON
      
      builder = Lucky::AssetBuilder::Mix.new
      result = builder.parse_manifest(manifest_json)
      
      result["js/app.js"].should eq("/js/app.12345.js")
      result["css/app.css"].should eq("/css/app.67890.css")
      result["images/logo.png"].should eq("/images/logo.abcde.png")
    end
    
    it "normalizes keys by removing leading slashes" do
      manifest_json = <<-JSON
      {
        "/assets/js/app.js": "/assets/js/app.12345.js"
      }
      JSON
      
      builder = Lucky::AssetBuilder::Mix.new
      result = builder.parse_manifest(manifest_json)
      
      result["js/app.js"].should eq("/assets/js/app.12345.js")
    end
  end
end