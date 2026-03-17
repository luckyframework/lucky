require "../../../spec_helper"

describe Lucky::Attachment::Extractor::MimeFromIO do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::MimeFromIO.new

    context "with a plain MIME type" do
      it "returns the MIME type" do
        uploaded_file = build_uploaded_file(content_type: "image/png")
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq("image/png")
      end
    end

    context "with a MIME type that includes parameters" do
      it "strips parameters and returns only the MIME type" do
        uploaded_file = build_uploaded_file(
          content_type: "text/plain; charset=utf-8"
        )
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq("text/plain")
      end

      it "strips multiple parameters" do
        uploaded_file = build_uploaded_file(
          content_type: "multipart/form-data; boundary=something; charset=utf-8"
        )
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq("multipart/form-data")
      end
    end

    context "with surrounding whitespace" do
      it "strips whitespace from the MIME type" do
        uploaded_file = build_uploaded_file(
          content_type: "  image/jpeg ; quality=80"
        )
        result = subject.extract(
          uploaded_file, metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq("image/jpeg")
      end
    end

    context "without a Content-Type header" do
      it "returns nil" do
        uploaded_file = build_uploaded_file(content_type: nil)
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should be_nil
      end
    end
  end
end

private def build_uploaded_file(content_type : String?) : Lucky::UploadedFile
  headers = HTTP::Headers.new
  headers["Content-Disposition"] = %[form-data; name="file"; filename="test.bin"]
  headers["Content-Type"] = content_type if content_type
  body = IO::Memory.new
  part = HTTP::FormData::Part.new(headers: headers, body: body)
  Lucky::UploadedFile.new(part)
end
