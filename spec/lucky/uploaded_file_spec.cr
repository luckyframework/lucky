require "../spec_helper"

include ContextHelper
include MultipartHelper

describe Lucky::UploadedFile do
  describe "#name" do
    it "returns the form data part name" do
      uploaded_file.name.should eq("welcome_file")
    end
  end

  describe "#tempfile" do
    it "returns the tempfile" do
      uploaded_file.tempfile.should be_a(File)
    end
  end

  describe "#metadata" do
    it "returns the metadata object" do
      uploaded_file.metadata.should be_a(HTTP::FormData::FileMetadata)
    end
  end

  describe "#path" do
    it "returns the file path" do
      uploaded_file.path.should match(/^\/tmp\/.*welcome_file$/)
    end
  end

  describe "#filename" do
    it "returns the original file from the metadata object" do
      uploaded_file.filename.should eq("welcome_file")
      uploaded_file.filename.should eq(uploaded_file.metadata.filename)
    end
  end

  describe "#blank?" do
    it "tests if the file name is blank" do
      uploaded_file.blank?.should be_falsey
    end
  end
end

private def uploaded_file
  Lucky::Params.new(build_multipart_request(file_parts: {
    "welcome_file" => "welcome file contents",
  })).get_file(:welcome_file)
end
