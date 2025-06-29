require "../../spec_helper"
require "../../../src/lucky/asset_builder/vite"

describe Lucky::AssetBuilder::Vite do
  describe "#manifest_path" do
    it "defaults to ./public/.vite/manifest.json" do
      builder = Lucky::AssetBuilder::Vite.new
      builder.manifest_path.should eq("./public/.vite/manifest.json")
    end
    
    it "accepts custom path" do
      builder = Lucky::AssetBuilder::Vite.new("/custom/vite.json")
      builder.manifest_path.should eq("/custom/vite.json")
    end
  end
  
  describe "#parse_manifest" do
    it "parses Vite manifest format correctly" do
      manifest_json = <<-JSON
      {
        "src/js/app.js": {
          "file": "assets/app.12345.js",
          "src": "src/js/app.js",
          "isEntry": true
        },
        "src/css/app.scss": {
          "file": "assets/app.67890.css",
          "src": "src/css/app.scss",
          "isEntry": true
        },
        "_shared-B7PI925R.js": {
          "file": "assets/shared-B7PI925R.js",
          "name": "shared"
        },
        "src/images/logo.png": {
          "file": "assets/logo.abcde.png",
          "src": "src/images/logo.png"
        }
      }
      JSON
      
      builder = Lucky::AssetBuilder::Vite.new
      result = builder.parse_manifest(manifest_json)
      
      result["js/app.js"].should eq("/assets/app.12345.js")
      result["css/app.scss"].should eq("/assets/app.67890.css")
      result["images/logo.png"].should eq("/assets/logo.abcde.png")
      # Shared chunks (starting with _) should be ignored
      result.has_key?("_shared-B7PI925R.js").should be_false
    end
    
    it "ignores entries without src property" do
      manifest_json = <<-JSON
      {
        "_chunk-ABC123.js": {
          "file": "assets/chunk-ABC123.js"
        },
        "style.css": {
          "file": "assets/style.12345.css"
        }
      }
      JSON
      
      builder = Lucky::AssetBuilder::Vite.new
      result = builder.parse_manifest(manifest_json)
      
      result.empty?.should be_true
    end
    
    it "strips src/ prefix from keys" do
      manifest_json = <<-JSON
      {
        "src/assets/images/logo.png": {
          "file": "images/logo.12345.png",
          "src": "src/assets/images/logo.png"
        }
      }
      JSON
      
      builder = Lucky::AssetBuilder::Vite.new
      result = builder.parse_manifest(manifest_json)
      
      result["images/logo.png"].should eq("/images/logo.12345.png")
    end
    
    it "handles keys without src/ prefix" do
      manifest_json = <<-JSON
      {
        "images/direct.png": {
          "file": "images/direct.12345.png",
          "src": "images/direct.png"
        }
      }
      JSON
      
      builder = Lucky::AssetBuilder::Vite.new
      result = builder.parse_manifest(manifest_json)
      
      result["images/direct.png"].should eq("/images/direct.12345.png")
    end
  end
end