require "../../spec_helper"
require "../../../src/lucky/asset_builder/base"

class TestAssetBuilder < Lucky::AssetBuilder::Base
  @manifest_path : String
  @manifest_content : Hash(String, String)

  def initialize(@manifest_path : String, @manifest_content : Hash(String, String))
  end

  def manifest_path : String
    @manifest_path
  end

  def parse_manifest(manifest_content : String) : Hash(String, String)
    @manifest_content
  end
end

describe Lucky::AssetBuilder::Base do
  describe "#normalize_key" do
    it "removes leading slash" do
      builder = TestAssetBuilder.new("test.json", {} of String => String)
      builder.normalize_key("/images/logo.png").should eq("images/logo.png")
    end

    it "removes assets/ prefix" do
      builder = TestAssetBuilder.new("test.json", {} of String => String)
      builder.normalize_key("assets/images/logo.png").should eq("images/logo.png")
    end

    it "removes both leading slash and assets/ prefix" do
      builder = TestAssetBuilder.new("test.json", {} of String => String)
      builder.normalize_key("/assets/images/logo.png").should eq("images/logo.png")
    end

    it "leaves other paths unchanged" do
      builder = TestAssetBuilder.new("test.json", {} of String => String)
      builder.normalize_key("images/logo.png").should eq("images/logo.png")
    end
  end

  describe "#load_manifest" do
    it "raises error when manifest doesn't exist" do
      builder = TestAssetBuilder.new("/non/existent/path.json", {} of String => String)

      expect_raises(Lucky::AssetBuilder::MissingManifestError) do
        builder.load_manifest
      end
    end
  end
end
