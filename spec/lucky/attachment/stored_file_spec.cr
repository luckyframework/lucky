require "../../spec_helper"

describe Lucky::Attachment::StoredFile do
  memory_store = Lucky::Attachment::Storage::Memory.new(base_url: "https://example.com")

  before_each do
    memory_store.clear!

    Lucky::Attachment.configure do |settings|
      settings.storages["store"] = memory_store
    end
  end

  describe ".from_json" do
    it "deserializes from JSON" do
      file = TestUploader::StoredFile.from_json(
        {
          id:       "test.jpg",
          storage:  "store",
          metadata: {
            filename:  "original.jpg",
            size:      1024_i64,
            mime_type: "image/jpeg",
          },
        }.to_json
      )

      file.id.should eq("test.jpg")
      file.storage_key.should eq("store")
      file.filename.should eq("original.jpg")
      file.size.should eq(1024)
      file.mime_type.should eq("image/jpeg")
    end
  end

  describe "#to_json" do
    it "serializes to JSON" do
      file = TestUploader::StoredFile.new(
        id: "test.jpg",
        storage_key: "store",
        metadata: Lucky::Attachment::MetadataHash{
          "filename"  => "original.jpg",
          "size"      => 1024_i64,
          "mime_type" => "image/jpeg",
        }
      )
      parsed = JSON.parse(file.to_json)

      parsed["id"].should eq("test.jpg")
      parsed["storage"].should eq("store")
      parsed["metadata"]["size"].should eq(1024_i64)
      parsed["metadata"]["filename"].should eq("original.jpg")
      parsed["metadata"]["mime_type"].should eq("image/jpeg")
    end
  end

  describe "#extension" do
    it "extracts from id" do
      file = TestUploader::StoredFile.new(
        id: "path/to/file.jpg",
        storage_key: "store"
      )

      file.extension.should eq("jpg")
    end

    it "falls back to filename metadata" do
      file = TestUploader::StoredFile.new(
        id: "abc123",
        storage_key: "store",
        metadata: Lucky::Attachment::MetadataHash{"filename" => "photo.png"}
      )

      file.extension.should eq("png")
    end

    it "returns nil when no extension can be determined" do
      file = TestUploader::StoredFile.new(
        id: "abc123",
        storage_key: "store"
      )

      file.extension?.should be_nil
    end
  end

  describe "#size" do
    it "returns Int64 from integer metadata" do
      file = TestUploader::StoredFile.new(
        id: "file.jpg",
        storage_key: "store",
        metadata: Lucky::Attachment::MetadataHash{"size" => 1024_i64}
      )

      file.size.should eq(1024_i64)
      file.size.should be_a(Int64)
    end

    it "coerces Int32 to Int64" do
      file = TestUploader::StoredFile.new(
        id: "file.jpg",
        storage_key: "store",
        metadata: Lucky::Attachment::MetadataHash{"size" => 512_i32}
      )

      file.size.should eq(512_i64)
      file.size.should be_a(Int64)
    end

    it "returns nil when size is absent" do
      file = TestUploader::StoredFile.new(
        id: "file.jpg",
        storage_key: "store"
      )

      file.size?.should be_nil
    end
  end

  describe "#url" do
    it "delegates to storage" do
      file = TestUploader::StoredFile.new(
        id: "uploads/photo.jpg",
        storage_key: "store"
      )

      file.url.should eq("https://example.com/uploads/photo.jpg")
    end
  end

  describe "#exists?" do
    it "returns true when file is in storage" do
      memory_store.upload(IO::Memory.new("data"), "photo.jpg")
      file = TestUploader::StoredFile.new(
        id: "photo.jpg",
        storage_key: "store"
      )

      file.exists?.should be_true
    end

    it "returns false when file is not in storage" do
      file = TestUploader::StoredFile.new(
        id: "missing.jpg",
        storage_key: "store"
      )
      file.exists?.should be_false
    end
  end

  describe "#open" do
    it "yields the file IO" do
      memory_store.upload(IO::Memory.new("file content"), "test.txt")
      file = TestUploader::StoredFile.new(
        id: "test.txt",
        storage_key: "store"
      )

      file.open(&.gets_to_end.should(eq("file content")))
    end

    it "closes the IO after the block" do
      memory_store.upload(IO::Memory.new("data"), "test.txt")
      file = TestUploader::StoredFile.new(id: "test.txt", storage_key: "store")
      captured_io = nil
      file.open { |io| captured_io = io }

      captured_io.as(IO).closed?.should be_true
    end

    it "closes the IO even if the block raises" do
      memory_store.upload(IO::Memory.new("data"), "test.txt")
      file = TestUploader::StoredFile.new(id: "test.txt", storage_key: "store")
      captured_io = nil

      expect_raises(Exception) do
        file.open do |io|
          captured_io = io
          raise "oops"
        end
      end
      captured_io.as(IO).closed?.should be_true
    end

    describe "#download" do
      it "returns a tempfile with file content" do
        memory_store.upload(IO::Memory.new("downloaded content"), "test.txt")
        file = TestUploader::StoredFile.new(id: "test.txt", storage_key: "store")
        tempfile = file.download

        tempfile.gets_to_end.should eq("downloaded content")
        tempfile.close
        tempfile.delete
      end

      it "works for files without an extension" do
        memory_store.upload(IO::Memory.new("binary data"), "abc123")
        file = TestUploader::StoredFile.new(id: "abc123", storage_key: "store")
        tempfile = file.download

        tempfile.gets_to_end.should eq("binary data")
        tempfile.close
        tempfile.delete
      end

      it "cleans up the tempfile after the block" do
        memory_store.upload(IO::Memory.new("data"), "test.txt")
        file = TestUploader::StoredFile.new(id: "test.txt", storage_key: "store")
        tempfile_path = ""
        file.download { |tempfile| tempfile_path = tempfile.path }

        File.exists?(tempfile_path).should be_false
      end
    end
  end

  describe "#delete" do
    it "removes the file from storage" do
      memory_store.upload(IO::Memory.new("data"), "test.txt")
      file = TestUploader::StoredFile.new(id: "test.txt", storage_key: "store")
      file.delete

      memory_store.exists?("test.txt").should be_false
    end
  end

  describe "#==" do
    it "is equal when id and storage_key match" do
      a = TestUploader::StoredFile.new(id: "file.jpg", storage_key: "store")
      b = TestUploader::StoredFile.new(id: "file.jpg", storage_key: "store")

      (a == b).should be_true
    end

    it "is not equal when id differs" do
      a = TestUploader::StoredFile.new(id: "a.jpg", storage_key: "store")
      b = TestUploader::StoredFile.new(id: "b.jpg", storage_key: "store")

      (a == b).should be_false
    end

    it "is not equal when storage_key differs" do
      a = TestUploader::StoredFile.new(id: "file.jpg", storage_key: "cache")
      b = TestUploader::StoredFile.new(id: "file.jpg", storage_key: "store")

      (a == b).should be_false
    end
  end
end

private struct TestUploader < Lucky::Attachment::Uploader; end
