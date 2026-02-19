require "../../spec_helper"

describe Lucky::Attachment::UploadedFile do
  describe ".from_json" do
    it "deserializes from JSON" do
      file = Lucky::Attachment::UploadedFile.from_json(
        {
          id:       "test.jpg",
          storage:  "store",
          metadata: {filename: "original.jpg", size: 1024},
        }.to_json
      )

      file.id.should eq("test.jpg")
      file.storage_key.should eq("store")
      file.original_filename.should eq("original.jpg")
      file.size.should eq(1024)
    end
  end

  describe "#to_json" do
    it "serializes to JSON" do
      file = Lucky::Attachment::UploadedFile.new(
        id: "test.jpg",
        storage_key: "store",
        metadata: Lucky::Attachment::MetadataHash{
          "filename" => "original.jpg",
          "size"     => 1024_i64,
        }
      )
      parsed = JSON.parse(file.to_json)

      parsed["id"].should eq("test.jpg")
      parsed["storage"].should eq("store")
      parsed["metadata"]["filename"].should eq("original.jpg")
    end
  end

  describe "#extension" do
    it "extracts from id" do
      file = Lucky::Attachment::UploadedFile.new(
        id: "path/to/file.jpg",
        storage_key: "store"
      )

      file.extension.should eq("jpg")
    end

    it "falls back to filename metadata" do
      file = Lucky::Attachment::UploadedFile.new(
        id: "abc123",
        storage_key: "store",
        metadata: Lucky::Attachment::MetadataHash{"filename" => "photo.png"}
      )

      file.extension.should eq("png")
    end
  end
end
