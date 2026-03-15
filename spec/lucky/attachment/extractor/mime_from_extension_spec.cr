require "../../../spec_helper"

describe Lucky::Attachment::Extractor::MimeFromExtension do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::MimeFromExtension.new

    context "when a filename is passed in options" do
      it "uses the filename from options over the IO filename" do
        io = IOWithFilename.new("ignored.png")
        result = subject.extract(io, metadata: nil, filename: "overridden.pdf")

        result.should eq("application/pdf")
      end
    end

    context "when the IO responds to #original_filename" do
      it "returns the MIME type for a known extension" do
        io = IOWithOriginalFilename.new("photo.png")
        result = subject.extract(io, metadata: nil)

        result.should eq("image/png")
      end

      it "returns nil when original_filename is nil" do
        io = IOWithOriginalFilename.new(nil)
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end

    context "when the IO responds to #filename" do
      it "returns the MIME type for a known extension" do
        io = IOWithFilename.new("document.pdf")
        result = subject.extract(io, metadata: nil)

        result.should eq("application/pdf")
      end

      it "returns nil when filename is nil" do
        io = IOWithFilename.new(nil)
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end

      it "returns nil when filename is blank" do
        io = IOWithFilename.new("")
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end

    context "when the IO responds to #path" do
      it "returns the MIME type using the basename of the path" do
        io = IOWithPath.new("/tmp/uploads/photo.png")
        result = subject.extract(io, metadata: nil)

        result.should eq("image/png")
      end

      it "handles a path with no directory component" do
        io = IOWithPath.new("photo.jpg")
        result = subject.extract(io, metadata: nil)

        result.should eq("image/jpeg")
      end
    end

    context "when the IO has no filename-related methods" do
      it "returns nil" do
        io = IO::Memory.new
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end

    context "when the filename has an unknown extension" do
      it "returns nil" do
        io = IOWithFilename.new("file.unknownextension")
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end

    context "when the filename has no extension" do
      it "returns nil" do
        io = IOWithFilename.new("Makefile")
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end

    context "when the filename has multiple dots" do
      it "uses only the last extension" do
        io = IOWithFilename.new("my.profile.photo.jpg")
        result = subject.extract(io, metadata: nil)

        result.should eq("image/jpeg")
      end
    end
  end
end

private class IOWithOriginalFilename < IO
  getter original_filename : String?

  def initialize(@original_filename : String?)
    @io = IO::Memory.new
  end

  delegate read, to: @io

  def write(slice : Bytes) : Nil
    @io.write(slice)
  end
end

private class IOWithFilename < IO
  getter filename : String?

  def initialize(@filename : String?)
    @io = IO::Memory.new
  end

  delegate read, to: @io

  def write(slice : Bytes) : Nil
    @io.write(slice)
  end
end

private class IOWithPath < IO
  getter path : String

  def initialize(@path : String)
    @io = IO::Memory.new
  end

  delegate read, to: @io

  def write(slice : Bytes) : Nil
    @io.write(slice)
  end
end
