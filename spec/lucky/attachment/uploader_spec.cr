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
    context "with a basic IO" do
      it "uploads and returns a stored file" do
        io = IO::Memory.new("hello")
        file = TestUploader.new("store").upload(io)

        file.should be_a(Lucky::Attachment::StoredFile)
        file.storage_key.should eq("store")
        file.exists?.should be_true
      end

      it "generates a unique location each time" do
        file_a = TestUploader.new("store").upload(IO::Memory.new("a"))
        file_b = TestUploader.new("store").upload(IO::Memory.new("b"))

        file_a.id.should_not eq(file_b.id)
      end

      it "extracts size metadata" do
        io = IO::Memory.new("hello world")
        file = TestUploader.new("store").upload(io)

        file.size.should eq(11)
      end

      it "preserves extension in the location" do
        io = IO::Memory.new("data")
        file = TestUploader.new("store").upload(
          io,
          metadata: Lucky::Attachment::MetadataHash{"filename" => "photo.jpg"}
        )

        file.id.should end_with(".jpg")
      end

      it "accepts a custom location" do
        io = IO::Memory.new("data")
        file = TestUploader.new("store").upload(io, location: "my/custom/path.jpg")

        file.id.should eq("my/custom/path.jpg")
      end

      it "merges provided metadata with extracted metadata" do
        io = IO::Memory.new("data")
        file = TestUploader.new("store").upload(
          io,
          metadata: Lucky::Attachment::MetadataHash{
            "filename" => "override.png",
            "custom"   => "value",
          }
        )

        file.original_filename.should eq("override.png")
        file["custom"].should eq("value")
      end
    end

    context "with a File IO" do
      it "extracts filename from path" do
        file = File.tempfile("myfile", ".txt", &.print("content"))
        uploaded = TestUploader.new("store").upload(File.open(file.path))

        uploaded.original_filename.should eq(File.basename(file.path))
      ensure
        file.try(&.delete)
      end

      it "extracts size" do
        file = File.tempfile("myfile", ".txt", &.print("content"))
        uploaded = TestUploader.new("store").upload(File.open(file.path))

        uploaded.size.should eq(7)
      ensure
        file.try(&.delete)
      end
    end

    context "error handling" do
      it "raises Error when no storages are not configured" do
        Lucky::Attachment.configure do |settings|
          settings.storages = {} of String => Lucky::Attachment::Storage
        end

        expect_raises(
          Lucky::Attachment::Error,
          "There are no storages registered yet"
        ) do
          TestUploader.new("store").upload(IO::Memory.new("data"))
        end
      end

      it "raises Error when a storage is not configured" do
        expect_raises(
          Lucky::Attachment::Error,
          %(Storage "missing" is not registered. The available storages are: "cache", "store")
        ) do
          TestUploader.new("missing").upload(IO::Memory.new("data"))
        end
      end
    end
  end

  describe "custom uploader behaviour" do
    it "uses overridden generate_location" do
      file = CustomLocationUploader.new("store").upload(IO::Memory.new("data"))

      file.id.should start_with("custom/")
    end

    it "uses overridden extract_metadata" do
      file = CustomMetadataUploader.new("store").upload(IO::Memory.new("data"))

      file["custom_key"].should eq("custom_value")
    end
  end

  describe ".cache" do
    it "uploads to the cache storage" do
      file = TestUploader.cache(IO::Memory.new("data"))

      file.storage_key.should eq("cache")
      memory_cache.exists?(file.id).should be_true
    end
  end

  describe ".store" do
    it "uploads to the store storage" do
      file = TestUploader.store(IO::Memory.new("data"))

      file.storage_key.should eq("store")
      memory_store.exists?(file.id).should be_true
    end
  end

  describe ".promote" do
    it "moves a cached file to the store" do
      cached = TestUploader.cache(IO::Memory.new("data"))
      stored = TestUploader.promote(cached)

      stored.storage_key.should eq("store")
      memory_store.exists?(stored.id).should be_true
    end

    it "deletes the source file by default" do
      cached = TestUploader.cache(IO::Memory.new("data"))
      cached_id = cached.id
      TestUploader.promote(cached)

      memory_cache.exists?(cached_id).should be_false
    end

    it "preserves the source when delete_source is false" do
      cached = TestUploader.cache(IO::Memory.new("data"))
      cached_id = cached.id
      TestUploader.promote(cached, delete_source: false)

      memory_cache.exists?(cached_id).should be_true
    end

    it "preserves the file id across storages" do
      cached = TestUploader.cache(IO::Memory.new("data"))
      stored = TestUploader.promote(cached)

      stored.id.should eq(cached.id)
    end

    it "preserves metadata" do
      cached = TestUploader.cache(
        IO::Memory.new("data"),
        metadata: Lucky::Attachment::MetadataHash{"filename" => "test.jpg"}
      )
      stored = TestUploader.promote(cached)

      stored.original_filename.should eq("test.jpg")
    end

    it "can promote to a custom storage key" do
      Lucky::Attachment.configure do |settings|
        settings.storages["cache"] = memory_cache
        settings.storages["store"] = memory_store
        settings.storages["offsite"] = Lucky::Attachment::Storage::Memory.new
      end
      cached = TestUploader.cache(IO::Memory.new("data"))
      offsite = TestUploader.promote(cached, to: "offsite")

      offsite.storage_key.should eq("offsite")
    end
  end
end

describe "Lucky::UploadedFile integration" do
  memory_store = Lucky::Attachment::Storage::Memory.new

  before_each do
    memory_store.clear!
    Lucky::Attachment.configure do |settings|
      settings.storages["store"] = memory_store
    end
  end

  it "extracts filename from Lucky::UploadedFile" do
    part = build_form_data_part("avatar", "photo.jpg", "image/jpeg", "data")
    lucky_file = Lucky::UploadedFile.new(part)
    uploaded = AvatarUploader.new("store").upload(lucky_file.tempfile)

    uploaded.original_filename.should eq(File.basename(lucky_file.tempfile.path))
  end

  it "extracts content_type when Lucky::UploadedFile exposes it" do
    part = build_form_data_part("avatar", "photo.jpg", "image/jpeg", "data")
    lucky_file = Lucky::UploadedFile.new(part)
    uploaded = AvatarUploader.new("store").upload(lucky_file.tempfile)

    uploaded.mime_type.should be_nil
  end

  it "handles blank files gracefully" do
    part = build_form_data_part("avatar", "", "application/octet-stream", "")
    lucky_file = Lucky::UploadedFile.new(part)

    lucky_file.blank?.should be_true
  end
end

private struct TestUploader < Lucky::Attachment::Uploader
end

private struct AvatarUploader < Lucky::Attachment::Uploader
end

private struct CustomLocationUploader < Lucky::Attachment::Uploader
  def generate_location(
    io : IO,
    metadata : Lucky::Attachment::MetadataHash,
  ) : String
    "custom/#{super}"
  end
end

private struct CustomMetadataUploader < Lucky::Attachment::Uploader
  def extract_metadata(
    io : IO,
    metadata : Lucky::Attachment::MetadataHash? = nil,
    **options,
  ) : Lucky::Attachment::MetadataHash
    data = super
    data["custom_key"] = "custom_value"
    data
  end
end

private def build_form_data_part(
  name : String,
  filename : String,
  content_type : String,
  body : String,
) : HTTP::FormData::Part
  disposition = if filename.empty?
                  %(form-data; name="#{name}")
                else
                  %(form-data; name="#{name}"; filename="#{filename}")
                end
  headers = HTTP::Headers{
    "Content-Disposition" => disposition,
    "Content-Type"        => content_type,
  }

  HTTP::FormData::Part.new(headers: headers, body: IO::Memory.new(body))
end
