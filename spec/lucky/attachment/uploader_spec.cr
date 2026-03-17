require "../../spec_helper"

describe Lucky::Attachment::Uploader do
  memory_cache = Lucky::Attachment::Storage::Memory.new
  memory_store = Lucky::Attachment::Storage::Memory.new

  before_each do
    memory_cache.clear!
    memory_store.clear!

    Lucky::Attachment.configure do |settings|
      settings.storages["cache"] = memory_cache
      settings.storages["store"] = memory_store
    end
  end

  describe "#upload" do
    it "uploads and returns a stored file" do
      uploaded_file = build_uploaded_file(content: "hello", filename: "test.txt")
      file = TestUploader.new("store").upload(uploaded_file)

      file.should be_a(TestUploader::StoredFile)
      file.storage_key.should eq("store")
      file.exists?.should be_true
    end

    it "generates a unique location each time" do
      file_a = TestUploader.new("store").upload(
        build_uploaded_file(content: "a", filename: "a.txt")
      )
      file_b = TestUploader.new("store").upload(
        build_uploaded_file(content: "b", filename: "b.txt")
      )

      file_a.id.should_not eq(file_b.id)
    end

    it "extracts size metadata" do
      uploaded_file = build_uploaded_file(content: "hello world", filename: "test.txt")
      file = TestUploader.new("store").upload(uploaded_file)

      file.size.should eq(11)
    end

    it "preserves extension in the location" do
      uploaded_file = build_uploaded_file(content: "data", filename: "photo.jpg")
      file = TestUploader.new("store").upload(uploaded_file)

      file.id.should end_with(".jpg")
    end

    it "accepts a custom location" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      file = TestUploader.new("store").upload(
        uploaded_file,
        location: "my/custom/path.jpg"
      )

      file.id.should eq("my/custom/path.jpg")
    end

    it "merges provided metadata with extracted metadata" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      file = TestUploader.new("store").upload(
        uploaded_file,
        metadata: Lucky::Attachment::MetadataHash{
          "filename" => "override.png",
          "custom"   => "value",
        }
      )

      file.filename.should eq("override.png")
      file["custom"]?.should eq("value")
    end

    context "error handling" do
      it "raises Error when no storages are configured" do
        Lucky::Attachment.configure do |settings|
          settings.storages = {} of String => Lucky::Attachment::Storage
        end

        expect_raises(
          Lucky::Attachment::Error,
          "There are no storages registered yet"
        ) do
          TestUploader.new("store").upload(
            build_uploaded_file(content: "data", filename: "test.txt")
          )
        end
      end

      it "raises Error when a storage is not configured" do
        expect_raises(
          Lucky::Attachment::Error,
          %(Storage "missing" is not registered. The available storages are: "cache", "store")
        ) do
          TestUploader.new("missing").upload(
            build_uploaded_file(content: "data", filename: "test.txt")
          )
        end
      end
    end
  end

  describe "custom uploader behaviour" do
    it "uses overridden generate_location" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      file = CustomLocationUploader.new("store").upload(uploaded_file)

      file.id.should start_with("custom/")
    end

    it "uses overridden extract_metadata" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      file = CustomMetadataUploader.new("store").upload(uploaded_file)

      file["custom_key"]?.should eq("custom_value")
    end
  end

  describe ".cache" do
    it "uploads to the cache storage" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      file = TestUploader.cache(uploaded_file)

      file.storage_key.should eq("cache")
      memory_cache.exists?(file.id).should be_true
    end
  end

  describe ".store" do
    it "uploads to the store storage" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      file = TestUploader.store(uploaded_file)

      file.storage_key.should eq("store")
      memory_store.exists?(file.id).should be_true
    end
  end

  describe ".promote" do
    it "moves a cached file to the store" do
      cached = TestUploader.cache(
        build_uploaded_file(content: "data", filename: "test.txt")
      )
      stored = TestUploader.promote(cached)

      stored.storage_key.should eq("store")
      memory_store.exists?(stored.id).should be_true
    end

    it "deletes the source file by default" do
      cached = TestUploader.cache(
        build_uploaded_file(content: "data", filename: "test.txt")
      )
      cached_id = cached.id
      TestUploader.promote(cached)

      memory_cache.exists?(cached_id).should be_false
    end

    it "preserves the source when delete_source is false" do
      cached = TestUploader.cache(
        build_uploaded_file(content: "data", filename: "test.txt")
      )
      cached_id = cached.id
      TestUploader.promote(cached, delete_source: false)

      memory_cache.exists?(cached_id).should be_true
    end

    it "preserves the file id across storages" do
      cached = TestUploader.cache(
        build_uploaded_file(content: "data", filename: "test.txt")
      )
      stored = TestUploader.promote(cached)

      stored.id.should eq(cached.id)
    end

    it "preserves metadata" do
      cached = TestUploader.cache(
        build_uploaded_file(content: "data", filename: "test.jpg"),
        metadata: Lucky::Attachment::MetadataHash{"filename" => "test.jpg"}
      )
      stored = TestUploader.promote(cached)

      stored.filename.should eq("test.jpg")
    end

    it "can promote to a custom storage key" do
      Lucky::Attachment.configure do |settings|
        settings.storages["cache"] = memory_cache
        settings.storages["store"] = memory_store
        settings.storages["offsite"] = Lucky::Attachment::Storage::Memory.new
      end
      cached = TestUploader.cache(
        build_uploaded_file(content: "data", filename: "test.txt")
      )
      offsite = TestUploader.promote(cached, to: "offsite")

      offsite.storage_key.should eq("offsite")
    end

    it "stores the file at the provided location" do
      cached = TestUploader.cache(
        build_uploaded_file(content: "data", filename: "test.txt")
      )
      stored = TestUploader.promote(cached, location: "custom/path/file.jpg")

      stored.id.should eq("custom/path/file.jpg")
      memory_store.exists?("custom/path/file.jpg").should be_true
    end

    it "uses the cached file id as location when none is provided" do
      cached = TestUploader.cache(
        build_uploaded_file(content: "data", filename: "test.txt")
      )
      stored = TestUploader.promote(cached)

      stored.id.should eq(cached.id)
    end
  end
end

private struct TestUploader < Lucky::Attachment::Uploader
end

private struct CustomLocationUploader < Lucky::Attachment::Uploader
  def generate_location(
    uploaded_file : Lucky::UploadedFile,
    metadata : Lucky::Attachment::MetadataHash,
    **options,
  ) : String
    "custom/#{super}"
  end
end

private struct CustomMetadataUploader < Lucky::Attachment::Uploader
  def extract_metadata(
    uploaded_file : Lucky::UploadedFile,
    metadata : Lucky::Attachment::MetadataHash? = nil,
    **options,
  ) : Lucky::Attachment::MetadataHash
    data = super
    data["custom_key"] = "custom_value"
    data
  end
end

private def build_uploaded_file(
  content : String,
  filename : String,
  size : Int32? = nil,
) : Lucky::UploadedFile
  headers = HTTP::Headers.new
  actual_size = size || content.bytesize
  headers["Content-Disposition"] =
    %[form-data; name="file"; filename="#{filename}"; size=#{actual_size}]
  body = IO::Memory.new(content)
  part = HTTP::FormData::Part.new(headers: headers, body: body)
  Lucky::UploadedFile.new(part)
end
