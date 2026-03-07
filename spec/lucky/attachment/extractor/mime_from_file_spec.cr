require "../../../spec_helper"

describe Lucky::Attachment::Extractor::MimeFromFile do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::MimeFromFile.new

    context "when the IO is empty" do
      it "returns nil without invoking the file utility" do
        io = IOWithSize.new("", size: 0_i64)
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end

    context "when the file utility is not installed" do
      it "raises Lucky::Attachment::Error" do
        original_path = ENV["PATH"]
        ENV["PATH"] = ""
        io = IOWithSize.new("Hello, world!")

        begin
          expect_raises(
            Lucky::Attachment::Error,
            "The `file` command-line tool is not installed"
          ) do
            subject.extract(io, metadata: nil)
          end
        ensure
          ENV["PATH"] = original_path
        end
      end
    end

    context "when the file utility is installed" do
      it "returns the MIME type for a PNG file" do
        png_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwADhQGAWjR9awAAAABJRU5ErkJggg=="
        png_bytes = Base64.decode(png_base64)
        path = File.tempfile("test", ".png", &.write(png_bytes)).path
        file = File.open(path)
        result = subject.extract(file, metadata: nil)

        result.should eq("image/png")
      ensure
        File.delete(path) if path
      end

      it "returns the MIME type for plain text" do
        io = IOWithSize.new("Hello, world!")
        result = subject.extract(io, metadata: nil)

        result.should eq("text/plain")
      end

      it "strips surrounding whitespace from the output" do
        io = IOWithSize.new("Hello, world!")
        result = subject.extract(io, metadata: nil)

        result.should eq(result.try &.strip)
      end

      it "rewinds the IO after reading" do
        io = IOWithSize.new("Hello, world!")
        subject.extract(io, metadata: nil)

        io.pos.should eq(0)
      end

      it "returns nil for a nil-size IO" do
        io = IOWithSize.new("hello", size: nil)
        result = subject.extract(io, metadata: nil)

        result.should_not be_nil
      end
    end
  end
end

private class IOWithSize < IO
  getter size : Int64?

  def initialize(content : String, @size : Int64? = nil)
    @io = IO::Memory.new(content)
    @size ||= content.bytesize.to_i64
  end

  delegate read, to: @io
  delegate rewind, to: @io
  delegate pos, to: @io

  def write(slice : Bytes) : Nil
    @io.write(slice)
  end
end
