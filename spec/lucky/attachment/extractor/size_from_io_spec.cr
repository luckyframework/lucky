require "../../../spec_helper"

describe Lucky::Attachment::Extractor::SizeFromIO do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::SizeFromIO.new

    context "when the IO responds to #tempfile" do
      it "returns the size of the tempfile" do
        tempfile = File.tempfile("test")
        tempfile.print("hello lucky")
        tempfile.flush

        begin
          io = IOWithTempfile.new(tempfile)
          result = subject.extract(io, metadata: nil)
          result.should eq(11_i64)
        ensure
          tempfile.delete
        end
      end

      it "prefers #tempfile over #size when both are present" do
        tempfile = File.tempfile("test")
        tempfile.print("hello")
        tempfile.flush

        begin
          io = IOWithTempfile.new(tempfile)
          result = subject.extract(io, metadata: nil)
          result.should eq(5_i64)
        ensure
          tempfile.delete
        end
      end
    end

    context "when the IO responds to #size but not #tempfile" do
      it "returns the size" do
        io = IOWithSize.new(42_i64)
        result = subject.extract(io, metadata: nil)

        result.should eq(42_i64)
      end

      it "returns 0 for an empty IO" do
        io = IOWithSize.new(0_i64)
        result = subject.extract(io, metadata: nil)

        result.should eq(0_i64)
      end
    end

    context "when the IO responds to neither #tempfile nor #size" do
      it "returns nil" do
        io = PlainIO.new
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end
  end
end

private class IOWithTempfile < IO
  getter tempfile : File

  def initialize(@tempfile : File)
  end

  delegate read, to: @tempfile

  def write(slice : Bytes) : Nil
    @tempfile.write(slice)
  end
end

private class IOWithSize < IO
  getter size : Int64

  def initialize(@size : Int64)
  end

  def read(slice : Bytes)
    raise "not implemented"
  end

  def write(slice : Bytes) : Nil
    raise "not implemented"
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
