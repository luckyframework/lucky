require "../../../spec_helper"

describe Lucky::Attachment::Storage::FileSystem do
  temp_dir = File.tempname("lucky_attachment_spec")

  before_each do
    Dir.mkdir_p(temp_dir)
  end

  after_each do
    FileUtils.rm_rf(temp_dir)
  end

  describe "#upload and #open" do
    it "writes and reads file content" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)
      storage.upload(IO::Memory.new("file content"), "test.txt")

      storage.open("test.txt").gets_to_end.should eq("file content")
    end

    it "creates intermediate directories" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)
      storage.upload(IO::Memory.new("data"), "a/b/c/test.txt")

      Dir.exists?(File.join(temp_dir, "a/b/c")).should be_true
    end

    it "respects the prefix" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir, prefix: "cache")
      storage.upload(IO::Memory.new("data"), "test.txt")

      File.exists?(File.join(temp_dir, "cache", "test.txt")).should be_true
    end
  end

  describe "#open" do
    it "raises FileNotFound for missing files" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)

      expect_raises(Lucky::Attachment::FileNotFound, /missing\.txt/) do
        storage.open("missing.txt")
      end
    end
  end

  describe "#exists?" do
    it "returns true for existing files" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)
      storage.upload(IO::Memory.new("data"), "test.txt")

      storage.exists?("test.txt").should be_true
    end

    it "returns false for missing files" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)

      storage.exists?("missing.txt").should be_false
    end
  end

  describe "#delete" do
    it "removes the file" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)
      storage.upload(IO::Memory.new("data"), "test.txt")
      storage.delete("test.txt")

      storage.exists?("test.txt").should be_false
    end

    it "cleans up empty parent directories by default" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)
      storage.upload(IO::Memory.new("data"), "a/b/test.txt")
      storage.delete("a/b/test.txt")

      Dir.exists?(File.join(temp_dir, "a/b")).should be_false
      Dir.exists?(File.join(temp_dir, "a")).should be_false
    end

    it "does not clean non-empty parent directories" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)
      storage.upload(IO::Memory.new("data"), "a/b/test1.txt")
      storage.upload(IO::Memory.new("data"), "a/b/test2.txt")
      storage.delete("a/b/test1.txt")

      Dir.exists?(File.join(temp_dir, "a/b")).should be_true
    end

    it "skips cleanup when clean is false" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir, clean: false)
      storage.upload(IO::Memory.new("data"), "a/b/test.txt")
      storage.delete("a/b/test.txt")

      Dir.exists?(File.join(temp_dir, "a/b")).should be_true
    end

    it "does not raise when deleting a missing file" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)

      storage.delete("nonexistent.txt")
    end
  end

  describe "#url" do
    it "returns a path from the root" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)

      storage.url("test.txt").should eq("/test.txt")
    end

    it "includes the prefix in the URL" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir, prefix: "uploads/cache")

      storage.url("test.txt").should eq("/uploads/cache/test.txt")
    end

    it "prepends host when provided" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)

      storage.url("test.txt", host: "https://example.com").should eq("https://example.com/test.txt")
    end
  end

  describe "#path_for" do
    it "returns the full filesystem path" do
      storage = Lucky::Attachment::Storage::FileSystem.new(temp_dir)

      storage.path_for("test.txt").should eq(File.join(File.expand_path(temp_dir), "test.txt"))
    end
  end
end
