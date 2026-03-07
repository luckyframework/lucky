require "../../../spec_helper"

describe Lucky::Attachment::Extractor::DimensionsFromIdentify do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::DimensionsFromIdentify.new
    png_path = "spec/fixtures/lucky_logo_tiny.png"

    context "when identify is not installed" do
      it "raises Lucky::Attachment::Error" do
        original_path = ENV["PATH"]
        ENV["PATH"] = ""
        io = IO::Memory.new

        begin
          expect_raises(
            Lucky::Attachment::Error,
            "The `identify` command-line tool is not installed"
          ) do
            subject.extract(io, metadata: Lucky::Attachment::MetadataHash.new)
          end
        ensure
          ENV["PATH"] = original_path
        end
      end
    end

    context "when identify is installed" do
      it "extracts width and height from a PNG file" do
        file = File.open(png_path)
        metadata = Lucky::Attachment::MetadataHash.new
        subject.extract(file, metadata: metadata)

        metadata["width"].should eq(69)
        metadata["height"].should eq(16)
      end

      it "does not modify metadata when identify returns no output" do
        io = IO::Memory.new
        metadata = Lucky::Attachment::MetadataHash.new
        subject.extract(io, metadata: metadata)

        metadata.should be_empty
      end

      it "rewinds the IO after reading" do
        file = File.open(png_path)
        metadata = Lucky::Attachment::MetadataHash.new
        subject.extract(file, metadata: metadata)

        file.pos.should eq(0)
      end
    end
  end
end
