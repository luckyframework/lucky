require "../../../spec_helper"

describe Lucky::Attachment::Extractor::MimeFromFile do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::MimeFromFile.new

    context "when the file is empty" do
      it "returns nil without invoking the file utility" do
        uploaded_file = build_uploaded_file(content: "", size: 0_u64)
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should be_nil
      end
    end

    context "when the file utility is not installed" do
      it "raises Lucky::Attachment::Error" do
        original_path = ENV["PATH"]
        ENV["PATH"] = ""
        uploaded_file = build_uploaded_file(content: "Hello, world!")

        begin
          expect_raises(
            Lucky::Attachment::Error,
            "The `file` command-line tool is not installed"
          ) do
            subject.extract(
              uploaded_file,
              metadata: {} of String => Lucky::Attachment::MetadataValue
            )
          end
        ensure
          ENV["PATH"] = original_path
        end
      end
    end

    context "when the file utility is installed" do
      it "returns the MIME type for a PNG file" do
        png_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAA" \
                     "DUlEQVR42mP8z8BQDwADhQGAWjR9awAAAABJRU5ErkJggg=="
        uploaded_file = build_uploaded_file(
          content: Base64.decode(png_base64),
          filename: "test.png"
        )
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq("image/png")
      end

      it "returns the MIME type for plain text" do
        uploaded_file = build_uploaded_file(content: "Hello, world!")
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq("text/plain")
      end

      it "strips surrounding whitespace from the output" do
        uploaded_file = build_uploaded_file(content: "Hello, world!")
        result = subject.extract(
          uploaded_file,
          metadata: {} of String => Lucky::Attachment::MetadataValue
        )

        result.should eq(result.try &.strip)
      end
    end
  end
end

private def build_uploaded_file(
  content : String | Bytes,
  filename : String = "test.bin",
  size : UInt64? = nil,
) : Lucky::UploadedFile
  headers = HTTP::Headers.new
  disposition = String.build do |io|
    io << %[form-data; name="file"; filename="#{filename}"]
    io << "; size=#{size}" if size
  end
  headers["Content-Disposition"] = disposition
  body = IO::Memory.new(content)
  part = HTTP::FormData::Part.new(headers: headers, body: body)
  Lucky::UploadedFile.new(part)
end
