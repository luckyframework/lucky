require "../../../spec_helper"

describe Lucky::Attachment::Extractor::DimensionsFromMagick do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::DimensionsFromMagick.new
    png_path = "spec/fixtures/lucky_logo_tiny.png"

    context "when neither magick nor identify is installed" do
      it "raises Lucky::Attachment::Error" do
        original_path = ENV["PATH"]
        ENV["PATH"] = ""
        uploaded_file = build_uploaded_file(filename: "test.png")

        begin
          expect_raises(
            Lucky::Attachment::Error,
            /The `magick|identify` command-line tool is not installed/
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

    context "when magick or identify is installed" do
      it "extracts width and height from a PNG file" do
        uploaded_file = build_uploaded_file(
          path: png_path,
          filename: "lucky_logo_tiny.png"
        )
        metadata = {} of String => Lucky::Attachment::MetadataValue
        result = subject.extract(uploaded_file, metadata: metadata)

        result.should be_nil
        metadata["width"].should eq(69)
        metadata["height"].should eq(16)
      end

      it "does not modify metadata for an unrecognised file" do
        uploaded_file = build_uploaded_file(filename: "empty.bin")
        metadata = {} of String => Lucky::Attachment::MetadataValue
        subject.extract(uploaded_file, metadata: metadata)

        metadata.should be_empty
      end
    end
  end
end

private def build_uploaded_file(
  filename : String,
  path : String? = nil,
) : Lucky::UploadedFile
  headers = HTTP::Headers.new
  headers["Content-Disposition"] =
    %[form-data; name="file"; filename="#{filename}"]
  body = path ? File.open(path) : IO::Memory.new
  part = HTTP::FormData::Part.new(headers: headers, body: body)
  Lucky::UploadedFile.new(part)
end
