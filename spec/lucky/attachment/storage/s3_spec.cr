require "../../../spec_helper"
require "webmock"

describe Lucky::Attachment::Storage::S3 do
  after_each do
    WebMock.reset
  end

  describe "#object_key" do
    it "returns the id when no prefix is configured" do
      storage = build_storage

      storage.object_key("photo.jpg").should eq("photo.jpg")
    end

    it "prepends the prefix" do
      storage = build_storage(prefix: "cache")

      storage.object_key("photo.jpg").should eq("cache/photo.jpg")
    end

    it "strips extra slashes from prefix and id" do
      storage = build_storage(prefix: "/cache/")

      storage.object_key("/photo.jpg").should eq("cache/photo.jpg")
    end
  end

  describe "#upload and #open" do
    it "writes and reads file content" do
      storage = build_storage
      WebMock.stub(:put, "#{base_url}/test.txt")
        .to_return(status: 200, headers: test_headers)
      WebMock.stub(:get, "#{base_url}/test.txt")
        .to_return(status: 200, body_io: test_file_io, headers: test_headers)

      storage.upload(test_file_io, "test.txt")

      storage.open("test.txt").gets_to_end.should eq("file content")
    end

    it "respects the prefix when uploading" do
      storage = build_storage(prefix: "cache")
      WebMock.stub(:put, "#{base_url}/cache/test.txt")
        .to_return(status: 200, headers: test_headers)

      storage.upload(IO::Memory.new("data"), "test.txt")
    end

    it "uses FileUploader for File inputs" do
      storage = build_storage
      WebMock.stub(:put, "#{base_url}/test.txt")
        .to_return(status: 200, headers: test_headers)

      File.tempfile("s3-test") do |tempfile|
        tempfile.print("file data")
        tempfile.rewind
        storage.upload(tempfile, "test.txt")
      end
    end
  end

  describe "#open" do
    it "raises FileNotFound when the object does not exist" do
      storage = build_storage
      WebMock.stub(:get, "#{base_url}/missing.txt")
        .to_return(status: 404, body: s3_error_xml("NoSuchKey", "Missing."))

      expect_raises(Lucky::Attachment::FileNotFound, /missing\.txt/) do
        storage.open("missing.txt")
      end
    end

    it "returns a rewindable IO" do
      storage = build_storage
      WebMock.stub(:get, "#{base_url}/test.txt")
        .to_return(status: 200, body_io: test_file_io("rewindable"))

      io = storage.open("test.txt")
      io.gets_to_end.should eq("rewindable")
      io.rewind
      io.gets_to_end.should eq("rewindable")
    end
  end

  describe "#exists?" do
    it "returns true when the object exists" do
      storage = build_storage
      WebMock.stub(:head, "#{base_url}/photo.jpg").to_return(status: 200)

      storage.exists?("photo.jpg").should be_true
    end

    it "returns false when the object does not exist" do
      storage = build_storage
      WebMock.stub(:head, "#{base_url}/missing.txt").to_return(status: 404)

      storage.exists?("missing.txt").should be_false
    end
  end

  describe "#delete" do
    it "sends a DELETE request for the object" do
      storage = build_storage
      WebMock.stub(:delete, "#{base_url}/photo.jpg").to_return(status: 204)

      storage.delete("photo.jpg")
    end

    it "uses the prefix in the DELETE path" do
      storage = build_storage(prefix: "cache")
      WebMock.stub(:delete, "#{base_url}/cache/photo.jpg").to_return(status: 204)

      storage.delete("photo.jpg")
    end
  end

  describe "#url" do
    describe "public URL (no expires_in)" do
      it "returns a standard AWS S3 URL" do
        storage = build_storage

        storage.url("photo.jpg").should eq(
          "https://s3-eu-west-1.amazonaws.com/lucky-bucket/photo.jpg"
        )
      end

      it "includes the prefix in the key" do
        storage = build_storage(prefix: "store")

        storage.url("photo.jpg").should eq(
          "https://s3-eu-west-1.amazonaws.com/lucky-bucket/store/photo.jpg"
        )
      end

      it "returns a custom-emdpoint URL for S3-compatible services" do
        storage = build_rustfs_storage

        storage.url("photo.jpg").should eq(
          "http://localhost:9000/lucky-bucket/photo.jpg"
        )
      end

      it "includes non-standard ports in the URL" do
        storage = Lucky::Attachment::Storage::S3.new(
          bucket: "lucky-bucket",
          region: "eu-west-1",
          access_key_id: "key",
          secret_access_key: "secret",
          endpoint: "http://localhost:9000"
        )

        storage.url("photo.jpg").should contain("http://localhost:9000")
      end

      it "omits standard ports from the URL" do
        storage = Lucky::Attachment::Storage::S3.new(
          bucket: "lucky-bucket",
          region: "eu-west-1",
          access_key_id: "key",
          secret_access_key: "secret",
          endpoint: "https://s3.example.com:443"
        )

        storage.url("photo.jpg").should eq(
          "https://s3.example.com/lucky-bucket/photo.jpg"
        )
      end
    end

    describe "#move" do
      it "falls back to upload for a plain IO" do
        storage = build_storage
        WebMock.stub(:put, "#{base_url}/dest.txt")
          .to_return(status: 200, headers: test_headers)

        storage.move(IO::Memory.new("data"), "dest.txt")
      end

      it "uses server-side copy and deletes the source for a same-bucket StoredFile" do
        storage = build_storage
        WebMock.stub(:put, "#{base_url}/store/photo.jpg")
          .to_return(status: 200, headers: test_headers, body: copy_object_xml)
        WebMock.stub(:delete, "#{base_url}/cache/photo.jpg")
          .to_return(status: 204)
        Lucky::Attachment.settings.storages["cache"] = storage

        source = TestUploader::StoredFile.new(
          id: "cache/photo.jpg",
          storage_key: "cache",
          metadata: Lucky::Attachment::MetadataHash.new
        )

        storage.move(source, "store/photo.jpg")
      end

      it "falls back to upload for a StoredFile from a different bucket" do
        storage = build_storage
        other_storage = build_storage(bucket: "other-bucket")
        Lucky::Attachment.settings.storages["other"] = other_storage
        WebMock.stub(:get, "https://s3-eu-west-1.amazonaws.com/other-bucket/photo.jpg")
          .to_return(status: 200, body_io: test_file_io("data"), headers: test_headers)
        WebMock.stub(:put, "#{base_url}/photo.jpg")
          .to_return(status: 200, headers: test_headers)
        source = TestUploader::StoredFile.new(
          id: "photo.jpg",
          storage_key: "other",
          metadata: Lucky::Attachment::MetadataHash.new
        )

        storage.move(source, "photo.jpg")
      end

      it "uses only the object key (not double-prefixed) when copying a same-bucket StoredFile" do
        storage = build_storage(prefix: "store")
        Lucky::Attachment.settings.storages["store"] = storage
        WebMock.stub(:put, "#{base_url}/store/photo.jpg?")
          .to_return(status: 200, body: copy_object_xml)
        WebMock.stub(:delete, "#{base_url}/store/photo.jpg?")
          .to_return(status: 204)

        source = TestUploader::StoredFile.new(
          id: "photo.jpg",
          storage_key: "store",
          metadata: Lucky::Attachment::MetadataHash.new
        )

        storage.move(source, "photo.jpg")
      end

      it "uses the source storage prefix for the copy source key" do
        cache_storage = build_storage(prefix: "cache")
        store_storage = build_storage

        Lucky::Attachment.settings.storages["cache"] = cache_storage
        Lucky::Attachment.settings.storages["store"] = store_storage

        WebMock.stub(:put, "#{base_url}/photo.jpg")
          .with(headers: {"x-amz-copy-source" => "/lucky-bucket/cache/photo.jpg"})
          .to_return(status: 200, body: copy_object_xml)

        source = TestUploader::StoredFile.new(
          id: "photo.jpg",
          storage_key: "cache",
          metadata: Lucky::Attachment::MetadataHash.new
        )

        store_storage.move(source, "photo.jpg")
      end
    end

    describe "presigned URL (with expires_in)" do
      it "returns a URL containing signature query parameters" do
        storage = build_storage
        url = storage.url("photo.jpg", expires_in: 3600)

        url.should contain("X-Amz-Signature")
        url.should contain("X-Amz-Expires=3600")
        url.should contain("photo.jpg")
      end

      it "includes the prefix in the presigned key" do
        storage = build_storage(prefix: "cache")
        url = storage.url("photo.jpg", expires_in: 3600)

        url.should contain("cache/photo.jpg")
      end

      it "uses the custom endpoint host for presigned URLs" do
        storage = build_rustfs_storage
        url = storage.url("photo.jpg", expires_in: 3600)

        url.should contain("localhost:9000")
      end
    end
  end

  describe "upload headers" do
    it "sets Content-Disposition from metadata filename" do
      client = TestAwss3Client.new
      build_storage(client: client).upload(
        IO::Memory.new, "test-id",
        metadata: Lucky::Attachment::MetadataHash{"filename" => "photo.jpg"},
      )

      client.headers["Content-Disposition"]
        .should eq(%(inline; filename="photo.jpg"))
    end

    it "sets Content-Type from metadata mime_type" do
      client = TestAwss3Client.new
      build_storage(client: client).upload(
        IO::Memory.new, "test-id",
        metadata: Lucky::Attachment::MetadataHash{"mime_type" => "image/jpeg"},
      )

      client.headers["Content-Type"].should eq("image/jpeg")
    end

    it "allows content_type to override metadata mime_type" do
      client = TestAwss3Client.new
      build_storage(client: client).upload(
        IO::Memory.new, "test-id",
        metadata: Lucky::Attachment::MetadataHash{"mime_type" => "image/jpeg"},
        content_type: "application/octet-stream"
      )

      client.headers["Content-Type"].should eq("application/octet-stream")
    end

    it "allows content_disposition to override metadata filename" do
      client = TestAwss3Client.new
      build_storage(client: client).upload(
        IO::Memory.new, "test-id",
        metadata: Lucky::Attachment::MetadataHash{"filename" => "photo.jpg"},
        content_disposition: "attachment"
      )

      client.headers["Content-Disposition"].should eq("attachment")
    end

    it "sets x-amz-acl: public-read when storage is public" do
      client = TestAwss3Client.new
      build_storage(client: client, public: true)
        .upload(IO::Memory.new, "test-id")

      client.headers["x-amz-acl"].should eq("public-read")
    end

    it "merges upload_options" do
      client = TestAwss3Client.new
      build_storage(
        client: client,
        upload_options: {"Cache-Control" => "max-age=31536000"}
      ).upload(IO::Memory.new, "test-id")

      client.headers["Cache-Control"].should eq("max-age=31536000")
    end

    it "per-call options take precedence over upload_options" do
      client = TestAwss3Client.new
      build_storage(
        client: client,
        upload_options: {"Content-Type" => "application/octet-stream"}
      ).upload(IO::Memory.new, "test-id", content_type: "image/jpeg")

      client.headers["Content-Type"].should eq("image/jpeg")
    end

    it "upload_options do not override metadata Content-Disposition" do
      client = TestAwss3Client.new
      build_storage(
        client: client,
        upload_options: {"Content-Disposition" => "attachment"}
      ).upload(
        IO::Memory.new, "test-id",
        metadata: Lucky::Attachment::MetadataHash{"filename" => "photo.jpg"}
      )

      client.headers["Content-Disposition"]
        .should eq(%(inline; filename="photo.jpg"))
    end
  end
end

private class TestAwss3Client < Awscr::S3::Client
  SIGNER = Awscr::Signer::Signers::V4.new("blah", "blah", "blah", "blah")

  getter headers = {} of String => String

  def initialize(
    @region = "eu-west-1",
    @aws_access_key = "test-key",
    @aws_secret_key = "test-secret",
    @endpoint = URI.new,
    @signer = SIGNER,
    @http = Awscr::S3::Http.new(SIGNER, URI.new),
  )
  end

  def put_object(_bucket, _id, _io, @headers)
  end
end

private struct TestUploader < Lucky::Attachment::Uploader; end

private def bucket
  "lucky-bucket"
end

private def region
  "eu-west-1"
end

private def base_url
  "https://s3-#{region}.amazonaws.com/#{bucket}"
end

private def test_headers(headers = {} of String => String)
  {"ETag" => %("abc123")}.merge(headers)
end

private def test_file_io(content = "file content")
  IO::Memory.new(content)
end

private def copy_object_xml
  <<-XML
  <?xml version="1.0" encoding="UTF-8"?>
  <CopyObjectResult>
    <ETag>"abc123"</ETag>
    <LastModified>2026-03-01T10:08:56.000Z</LastModified>
  </CopyObjectResult>
  XML
end

private def s3_error_xml(code : String, message : String) : String
  <<-XML
  <?xml version="1.0" encoding="UTF-8"?>
  <Error>
    <Code>#{code}</Code>
    <Message>#{message}</Message>
  </Error>
  XML
end

private def build_storage(
  bucket = "lucky-bucket",
  region = "eu-west-1",
  access_key_id = "test-key",
  secret_access_key = "test-secret",
  prefix = nil,
  public = false,
  upload_options = Hash(String, String).new,
  endpoint = nil,
  client = nil,
)
  if s3_client = client
    Lucky::Attachment::Storage::S3.new(
      bucket: bucket,
      client: s3_client,
      prefix: prefix,
      public: public,
      upload_options: upload_options
    )
  else
    Lucky::Attachment::Storage::S3.new(
      bucket: bucket,
      region: region,
      access_key_id: "test-key",
      secret_access_key: "test-secret",
      prefix: prefix,
      endpoint: endpoint,
      public: public,
      upload_options: upload_options
    )
  end
end

private def build_rustfs_storage(bucket = "lucky-bucket", prefix = nil)
  build_storage(
    bucket: bucket,
    access_key_id: "rustfsadmin",
    secret_access_key: "rustfsadmin",
    prefix: prefix,
    endpoint: "http://localhost:9000"
  )
end
