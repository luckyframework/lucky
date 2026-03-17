require "../../../spec_helper"

describe Lucky::Attachment::Extractor::SizeFromIO do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::SizeFromIO.new

    context "when the uploaded file has a known size" do
      it "returns the size" do
        uploaded_file = build_uploaded_file(
          content: "hello lucky",
          filename: "test.txt"
        )
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq(11_i64)
      end

      it "returns 0 for an empty file" do
        uploaded_file = build_uploaded_file(
          content: "",
          filename: "empty.txt"
        )
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq(0_i64)
      end
    end
  end
end

private def build_uploaded_file(
  content : String,
  filename : String,
) : Lucky::UploadedFile
  headers = HTTP::Headers.new
  headers["Content-Disposition"] =
    %[form-data; name="file"; filename="#{filename}"; size=#{content.bytesize}]
  body = IO::Memory.new(content)
  part = HTTP::FormData::Part.new(headers: headers, body: body)
  Lucky::UploadedFile.new(part)
end
