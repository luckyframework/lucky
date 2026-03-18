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

  describe "#storage" do
    it "returns the storage for the given key" do
      TestUploader.new("store").storage.should eq(memory_store)
    end
  end

  describe "#generate_location" do
    it "generates a UUID-based filename with extension" do
      uploaded_file = build_uploaded_file(content: "data", filename: "photo.jpg")
      uploader = TestUploader.new("store")
      metadata = Lucky::Attachment::MetadataHash{"filename" => "photo.jpg"}
      location = uploader.generate_location(uploaded_file, metadata)

      location.should match(/\A[0-9a-f-]{36}\.jpg\z/)
    end

    it "omits extension when filename has none" do
      uploaded_file = build_uploaded_file(content: "data", filename: "noext")
      uploader = TestUploader.new("store")
      metadata = Lucky::Attachment::MetadataHash{"filename" => "noext"}
      location = uploader.generate_location(uploaded_file, metadata)

      location.should match(/\A[0-9a-f-]{36}\z/)
    end

    it "prepends path_prefix when provided" do
      uploaded_file = build_uploaded_file(content: "data", filename: "photo.jpg")
      uploader = TestUploader.new("store")
      metadata = Lucky::Attachment::MetadataHash{"filename" => "photo.jpg"}
      location = uploader.generate_location(uploaded_file, metadata, path_prefix: "uploads")

      location.should match(/\Auploads[\/\\][0-9a-f-]{36}\.jpg\z/)
    end
  end

  describe "#generate_uid" do
    it "returns a valid UUID" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      uploader = TestUploader.new("store")
      uid = uploader.generate_uid(uploaded_file, Lucky::Attachment::MetadataHash.new)

      UUID.parse?(uid).should_not be_nil
    end

    it "returns a unique value each call" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      uploader = TestUploader.new("store")
      metadata = Lucky::Attachment::MetadataHash.new

      uploader.generate_uid(uploaded_file, metadata)
        .should_not eq(uploader.generate_uid(uploaded_file, metadata))
    end
  end

  describe "#extract_metadata" do
    it "runs all default extractors" do
      uploaded_file = build_uploaded_file(
        content: "data",
        filename: "test.txt",
        content_type: "text/plain"
      )
      data = TestUploader.new("store").extract_metadata(uploaded_file)

      data["filename"]?.should_not be_nil
      data["mime_type"]?.should_not be_nil
      data["size"]?.should_not be_nil
    end

    it "does not mutate the provided metadata hash" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      original = Lucky::Attachment::MetadataHash{"custom" => "value"}
      TestUploader.new("store").extract_metadata(uploaded_file, original)

      original.size.should eq(1)
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

    it "does not lose extracted metadata when extra metadata is passed" do
      uploaded_file = build_uploaded_file(content: "hello", filename: "test.txt")
      file = TestUploader.new("store").upload(
        uploaded_file,
        metadata: Lucky::Attachment::MetadataHash{"custom" => "value"}
      )

      file.size.should eq(5)
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

  describe "extract macro" do
    it "registers a custom extractor and exposes accessor methods" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      file = CustomExtractorUploader.new("store").upload(uploaded_file)

      file.custom_key?.should eq("custom_value")
      file.custom_key.should eq("custom_value")
    end

    it "overwrites a default extractor" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      file = OverriddenExtractorUploader.new("store").upload(uploaded_file)

      file.mime_type.should eq("text/plain")
    end
  end

  describe ".storages" do
    it "returns the default cache and store keys" do
      TestUploader.storages[:cache].should eq("cache")
      TestUploader.storages[:store].should eq("store")
    end

    it "returns overridden keys in a subclass" do
      CustomStoragesUploader.storages[:cache].should eq("tmp")
      CustomStoragesUploader.storages[:store].should eq("offsite")
    end
  end

  describe ".path_prefix" do
    it "returns the configured path prefix" do
      Lucky::Attachment.configure do |settings|
        settings.path_prefix = "uploads"
      end

      TestUploader.path_prefix.should eq("uploads")
    end
  end

  describe ".cache" do
    it "uploads to the cache storage" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      file = TestUploader.cache(uploaded_file)

      file.storage_key.should eq("cache")
      memory_cache.exists?(file.id).should be_true
    end

    it "uses the overridden cache storage key" do
      memory_tmp = Lucky::Attachment::Storage::Memory.new
      Lucky::Attachment.configure do |settings|
        settings.storages["tmp"] = memory_tmp
      end

      file = CustomStoragesUploader.cache(
        build_uploaded_file(content: "data", filename: "test.txt")
      )

      file.storage_key.should eq("tmp")
      memory_tmp.exists?(file.id).should be_true
    end
  end

  describe ".store" do
    it "uploads to the store storage" do
      uploaded_file = build_uploaded_file(content: "data", filename: "test.txt")
      file = TestUploader.store(uploaded_file)

      file.storage_key.should eq("store")
      memory_store.exists?(file.id).should be_true
    end

    it "uses the overridden store storage key" do
      memory_offsite = Lucky::Attachment::Storage::Memory.new
      Lucky::Attachment.configure do |settings|
        settings.storages["offsite"] = memory_offsite
      end

      file = CustomStoragesUploader.store(
        build_uploaded_file(content: "data", filename: "test.txt")
      )

      file.storage_key.should eq("offsite")
      memory_offsite.exists?(file.id).should be_true
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

    it "defaults to the overridden store storage key" do
      memory_tmp = Lucky::Attachment::Storage::Memory.new
      memory_offsite = Lucky::Attachment::Storage::Memory.new
      Lucky::Attachment.configure do |settings|
        settings.storages["tmp"] = memory_tmp
        settings.storages["offsite"] = memory_offsite
      end

      cached = CustomStoragesUploader.cache(
        build_uploaded_file(content: "data", filename: "test.txt")
      )
      stored = CustomStoragesUploader.promote(cached)

      stored.storage_key.should eq("offsite")
      memory_offsite.exists?(stored.id).should be_true
    end
  end
end

private struct TestUploader < Lucky::Attachment::Uploader
end

private struct CustomStoragesUploader < Lucky::Attachment::Uploader
  def self.storages : NamedTuple(cache: String, store: String)
    {cache: "tmp", store: "offsite"}
  end
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

private struct StaticExtractor
  include Lucky::Attachment::Extractor

  def extract(
    uploaded_file : Lucky::UploadedFile,
    metadata : Lucky::Attachment::MetadataHash,
    **options,
  ) : String?
    "custom_value"
  end
end

private struct StaticMimeExtractor
  include Lucky::Attachment::Extractor

  def extract(
    uploaded_file : Lucky::UploadedFile,
    metadata : Lucky::Attachment::MetadataHash,
    **options,
  ) : String?
    "text/plain"
  end
end

private struct CustomExtractorUploader < Lucky::Attachment::Uploader
  extract custom_key, using: StaticExtractor
end

private struct OverriddenExtractorUploader < Lucky::Attachment::Uploader
  extract mime_type, using: StaticMimeExtractor
end

private def build_uploaded_file(
  content : String,
  filename : String,
  size : Int32? = nil,
  content_type : String? = nil,
) : Lucky::UploadedFile
  headers = HTTP::Headers.new
  actual_size = size || content.bytesize
  headers["Content-Disposition"] =
    %[form-data; name="file"; filename="#{filename}"; size=#{actual_size}]
  headers["Content-Type"] = content_type if content_type
  body = IO::Memory.new(content)
  part = HTTP::FormData::Part.new(headers: headers, body: body)
  Lucky::UploadedFile.new(part)
end
