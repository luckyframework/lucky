require "../../spec_helper"

describe Lucky::Attachment::Uploader do
  before_each do
    Lucky::Attachment.configure do |settings|
      settings.storages["cache"] = Lucky::Attachment::Storage::Memory.new
      settings.storages["store"] = Lucky::Attachment::Storage::Memory.new
    end
  end

  describe "#upload" do
    it "uploads a file and returns UploadedFile" do
      uploader = TestAttachmentUploader.new("store")
      io = IO::Memory.new("test content")

      file = uploader.upload(io)

      file.should be_a(Lucky::Attachment::UploadedFile)
      file.storage_key.should eq("store")
      file.exists?.should be_true
    end

    it "extracts metadata" do
      uploader = TestAttachmentUploader.new("store")
      io = IO::Memory.new("test content")

      file = uploader.upload(io)

      file.size.should eq(12)
    end

    it "accepts custom metadata" do
      uploader = TestAttachmentUploader.new("store")
      io = IO::Memory.new("test")

      file = uploader.upload(io, metadata: {"custom" => "value"})

      file["custom"].should eq("value")
    end
  end

  describe ".cache" do
    it "uploads to cache storage" do
      io = IO::Memory.new("test")

      file = TestAttachmentUploader.cache(io)

      file.storage_key.should eq("cache")
    end
  end

  describe ".promote" do
    it "moves file from cache to store" do
      cached = TestAttachmentUploader.cache(IO::Memory.new("test"))

      stored = TestAttachmentUploader.promote(cached)

      stored.storage_key.should eq("store")
      cached.exists?.should be_false
    end
  end
end

struct TestAttachmentUploader < Lucky::Attachment::Uploader
end
