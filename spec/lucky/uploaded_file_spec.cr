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

    it "can be read" do
      uploaded_file.tempfile.gets_to_end.should eq("welcome file contents")
    end
  end

  describe "#path" do
    it "returns the file path" do
      uploaded_file.path.starts_with?(Dir.tempdir).should be_true
      uploaded_file.path.ends_with?("welcome_file").should be_true
    end
  end

  describe "#filename" do
    it "returns the original file from the metadata object" do
      uploaded_file.filename.should eq("welcome_file")
    end

    it "generates random filename for files without names" do
      nameless_uploaded_file.filename.should_not be_empty
    end
  end

  describe "#blank?" do
    it "tests if the file name is blank" do
      uploaded_file.blank?.should be_false
      empty_uploaded_file.blank?.should be_true
    end
  end

  describe "lazy writing" do
    it "does not write to disk when the request is parsed" do
      file = uploaded_file_named("lazy_parse_marker")

      file.filename.should eq("lazy_parse_marker")
      file.name.should eq("upload")
      file.blank?.should be_false
      tempfiles_matching("lazy_parse_marker").should be_empty
    end

    it "writes the tempfile the first time it is requested" do
      file = uploaded_file_named("lazy_write_marker")

      path = file.path

      tempfiles_matching("lazy_write_marker").should eq([path])
      File.read(path).should eq("contents")
      file.tempfile.path.should eq(path)
      file.delete
    end
  end

  describe "#delete" do
    it "removes the tempfile" do
      file = uploaded_file
      path = file.path
      File.exists?(path).should be_true

      file.delete

      File.exists?(path).should be_false
    end

    it "does nothing when the tempfile was never written" do
      file = uploaded_file_named("lazy_delete_marker")

      file.delete

      tempfiles_matching("lazy_delete_marker").should be_empty
    end

    it "can be called more than once" do
      file = uploaded_file
      path = file.path

      file.delete
      file.delete

      File.exists?(path).should be_false
    end
  end
end

private def tempfiles_matching(marker : String) : Array(String)
  Dir.glob(File.join(Dir.tempdir, "*#{marker}"))
end

private def uploaded_file_named(filename : String)
  form_io, content_type = IO::Memory.new, ""
  HTTP::FormData.build(form_io) do |formdata|
    content_type = formdata.content_type
    metadata = HTTP::FormData::FileMetadata.new(filename: filename)
    formdata.file("upload", IO::Memory.new("contents"), metadata, HTTP::Headers{"Content-Type" => "text/plain"})
  end
  request = build_request(method: "POST", body: form_io.to_s, content_type: content_type)
  Lucky::Params.new(request).get_file(:upload)
end

private def empty_uploaded_file
  Lucky::Params.new(build_multipart_request(file_parts: {
    "empty_file" => "",
  })).get_file(:empty_file)
end

private def nameless_uploaded_file
  Lucky::Params.new(build_multipart_request(file_parts: {
    "" => "nameless file contents",
  })).from_multipart[1][""]
end

private def uploaded_file
  Lucky::Params.new(build_multipart_request(file_parts: {
    "welcome_file" => "welcome file contents",
  })).get_file(:welcome_file)
end
