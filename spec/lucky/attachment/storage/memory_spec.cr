require "../../../spec_helper"

describe Lucky::Attachment::Storage::Memory do
  describe "#upload and #open" do
    it "stores and retrieves file content" do
      storage = Lucky::Attachment::Storage::Memory.new
      io = IO::Memory.new("hello world")

      storage.upload(io, "test.txt")

      result = storage.open("test.txt")
      result.gets_to_end.should eq("hello world")
    end
  end

  describe "#exists?" do
    it "returns true for existing files" do
      storage = Lucky::Attachment::Storage::Memory.new
      storage.upload(IO::Memory.new("test"), "test.txt")

      storage.exists?("test.txt").should be_true
    end

    it "returns false for non-existing files" do
      storage = Lucky::Attachment::Storage::Memory.new

      storage.exists?("missing.txt").should be_false
    end
  end

  describe "#delete" do
    it "removes the file" do
      storage = Lucky::Attachment::Storage::Memory.new
      storage.upload(IO::Memory.new("test"), "test.txt")

      storage.delete("test.txt")

      storage.exists?("test.txt").should be_false
    end
  end

  describe "#url" do
    it "returns path without base_url" do
      storage = Lucky::Attachment::Storage::Memory.new

      storage.url("path/to/file.jpg").should eq("/path/to/file.jpg")
    end

    it "includes base_url when set" do
      storage = Lucky::Attachment::Storage::Memory.new(base_url: "https://example.com")

      storage.url("path/to/file.jpg").should eq("https://example.com/path/to/file.jpg")
    end
  end
end
