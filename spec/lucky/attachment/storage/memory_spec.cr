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

    it "overwrites existing content" do
      storage = Lucky::Attachment::Storage::Memory.new
      storage.upload(IO::Memory.new("original"), "test.txt")
      storage.upload(IO::Memory.new("updated"), "test.txt")

      storage.open("test.txt").gets_to_end.should eq("updated")
    end
  end

  describe "#open" do
    it "raises FileNotFound for missing files" do
      storage = Lucky::Attachment::Storage::Memory.new

      expect_raises(Lucky::Attachment::FileNotFound, /missing\.txt/) do
        storage.open("missing.txt")
      end
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

    it "does not raise when deleting a missing file" do
      storage = Lucky::Attachment::Storage::Memory.new

      storage.delete("nonexistent.txt")
    end
  end

  describe "#url" do
    it "returns path without base_url" do
      storage = Lucky::Attachment::Storage::Memory.new

      storage.url("path/to/file.jpg").should eq("/path/to/file.jpg")
    end

    it "prepends base_url when configured" do
      storage = Lucky::Attachment::Storage::Memory.new(base_url: "https://cdn.example.com")

      storage.url("path/to/file.jpg").should eq("https://cdn.example.com/path/to/file.jpg")
    end

    it "handles base_url with trailing slash" do
      storage = Lucky::Attachment::Storage::Memory.new(base_url: "https://cdn.example.com/")

      storage.url("path/to/file.jpg").should eq("https://cdn.example.com/path/to/file.jpg")
    end
  end

  describe "#clear!" do
    it "removes all files" do
      storage = Lucky::Attachment::Storage::Memory.new
      storage.upload(IO::Memory.new("a"), "a.txt")
      storage.upload(IO::Memory.new("b"), "b.txt")
      storage.clear!

      storage.size.should eq(0)
    end
  end
end
