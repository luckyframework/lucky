require "../../../spec_helper"

describe Lucky::Attachment::Extractor::FilenameFromIO do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::FilenameFromIO.new

    context "when a filename is provided in options" do
      it "returns the filename from options" do
        io = PlainIO.new
        result = subject.extract(io, metadata: nil, filename: "override.txt")

        result.should eq("override.txt")
      end

      it "prefers options filename over #original_filename" do
        io = IOWithOriginalFilename.new("ignored.txt")
        result = subject.extract(io, metadata: nil, filename: "override.txt")

        result.should eq("override.txt")
      end
    end

    context "when the IO responds to #original_filename" do
      it "returns the original filename" do
        io = IOWithOriginalFilename.new("photo.jpg")
        result = subject.extract(io, metadata: nil)

        result.should eq("photo.jpg")
      end

      it "returns nil when original_filename is nil" do
        io = IOWithOriginalFilename.new(nil)
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end

    context "when the IO responds to #filename but not #original_filename" do
      it "returns the filename" do
        io = IOWithFilename.new("document.pdf")
        result = subject.extract(io, metadata: nil)

        result.should eq("document.pdf")
      end

      it "returns nil when filename is blank" do
        io = IOWithFilename.new("")
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end

      it "returns nil when filename is nil" do
        io = IOWithFilename.new(nil)
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end

    context "when the IO responds to #path but not #original_filename or #filename" do
      it "returns the basename of the path" do
        io = IOWithPath.new("/uploads/tmp/archive.zip")
        result = subject.extract(io, metadata: nil)

        result.should eq("archive.zip")
      end

      it "returns just the filename when path has no directory component" do
        io = IOWithPath.new("archive.zip")
        result = subject.extract(io, metadata: nil)

        result.should eq("archive.zip")
      end
    end

    context "when the IO responds to none of the known methods" do
      it "returns nil" do
        io = PlainIO.new
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end
  end
end

private class PlainIO < IO
  def read(slice : Bytes)
    raise "not implemented"
  end

  def write(slice : Bytes) : Nil
    raise "not implemented"
  end
end

private class IOWithOriginalFilename < IO
  getter original_filename : String?

  def initialize(@original_filename : String?)
  end

  def read(slice : Bytes)
    raise "not implemented"
  end

  def write(slice : Bytes) : Nil
    raise "not implemented"
  end
end

private class IOWithFilename < IO
  getter filename : String?

  def initialize(@filename : String?)
  end

  def read(slice : Bytes)
    raise "not implemented"
  end

  def write(slice : Bytes) : Nil
    raise "not implemented"
  end
end

private class IOWithPath < IO
  getter path : String

  def initialize(@path : String)
  end

  def read(slice : Bytes)
    raise "not implemented"
  end

  def write(slice : Bytes) : Nil
    raise "not implemented"
  end
end
