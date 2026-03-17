require "../../../spec_helper"

describe Lucky::Attachment::Extractor::MimeFromExtension do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::MimeFromExtension.new

    context "with a known extension" do
      it "returns the MIME type for a PNG file" do
        uploaded_file = build_uploaded_file(filename: "photo.png")
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq("image/png")
      end

      it "returns the MIME type for a PDF file" do
        uploaded_file = build_uploaded_file(filename: "document.pdf")
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq("application/pdf")
      end

      it "uses only the last extension for dotted filenames" do
        uploaded_file = build_uploaded_file(filename: "my.profile.photo.jpg")
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq("image/jpeg")
      end
    end

    context "with an unknown or missing extension" do
      it "returns nil for an unknown extension" do
        uploaded_file = build_uploaded_file(filename: "file.unknownextension")
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should be_nil
      end

      it "returns nil for a filename with no extension" do
        uploaded_file = build_uploaded_file(filename: "Makefile")
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should be_nil
      end
    end
  end
end

private def build_uploaded_file(filename : String) : Lucky::UploadedFile
  headers = HTTP::Headers.new
  headers["Content-Disposition"] =
    %[form-data; name="file"; filename="#{filename}"]
  body = IO::Memory.new
  part = HTTP::FormData::Part.new(headers: headers, body: body)
  Lucky::UploadedFile.new(part)
end
