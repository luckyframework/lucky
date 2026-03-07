require "../../../spec_helper"

describe Lucky::Attachment::Extractor::MimeFromIO do
  describe "#extract" do
    subject = Lucky::Attachment::Extractor::MimeFromIO.new

    context "when the IO responds to #content_type" do
      context "and content_type is a plain MIME type" do
        it "returns the MIME type" do
          io = IOWithContentType.new("image/png")
          result = subject.extract(io, metadata: nil)

          result.should eq("image/png")
        end
      end

      context "and content_type includes parameters (e.g. charset)" do
        it "strips parameters and returns only the MIME type" do
          io = IOWithContentType.new("text/plain; charset=utf-8")
          result = subject.extract(io, metadata: nil)

          result.should eq("text/plain")
        end
      end

      context "and content_type includes multiple parameters" do
        it "strips all parameters and returns only the MIME type" do
          io = IOWithContentType.new("multipart/form-data; boundary=something; charset=utf-8")
          result = subject.extract(io, metadata: nil)

          result.should eq("multipart/form-data")
        end
      end

      context "and content_type has surrounding whitespace" do
        it "strips whitespace from the MIME type" do
          io = IOWithContentType.new("  image/jpeg ; quality=80")
          result = subject.extract(io, metadata: nil)

          result.should eq("image/jpeg")
        end
      end

      context "and content_type is nil" do
        it "returns nil" do
          io = IOWithContentType.new(nil)
          result = subject.extract(io, metadata: nil)

          result.should be_nil
        end
      end
    end

    context "when the IO does not respond to #content_type" do
      it "returns nil" do
        io = IO::Memory.new
        result = subject.extract(io, metadata: nil)

        result.should be_nil
      end
    end
  end
end

private class IOWithContentType < IO
  getter content_type : String?

  def initialize(@content_type : String?)
    @io = IO::Memory.new
  end

  delegate read, to: @io

  def write(slice : Bytes) : Nil
    @io.write(slice)
  end
end
