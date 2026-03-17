require "../../../spec_helper"

describe Lucky::Attachment::Extractor::FilenameFromIO do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::FilenameFromIO.new

    context "when a filename is provided in options" do
      it "returns the filename from options, ignoring the uploaded file's filename" do
        uploaded_file = build_uploaded_file(filename: "original.jpg")
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue,
          filename: "override.txt"
        )

        result.should eq("override.txt")
      end
    end

    context "when no filename option is given" do
      it "returns the filename from the uploaded file" do
        uploaded_file = build_uploaded_file(filename: "photo.jpg")
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq("photo.jpg")
      end

      it "falls back to the basename of the tempfile path when filename is blank" do
        uploaded_file = build_uploaded_file(filename: nil)
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should match(/^\w{24}$/)
      end
    end
  end
end

private def build_uploaded_file(filename : String?) : Lucky::UploadedFile
  headers = HTTP::Headers.new
  headers["Content-Disposition"] = content_disposition(filename)
  body = IO::Memory.new
  part = HTTP::FormData::Part.new(headers: headers, body: body)
  Lucky::UploadedFile.new(part)
end

private def content_disposition(filename)
  if filename.presence
    %[form-data; name="file"; filename="#{filename}"]
  else
    %[form-data; name="file"]
  end
end
