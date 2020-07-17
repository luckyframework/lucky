require "../spec_helper"

include ContextHelper

describe Lucky::FileResponse do
  describe "#print" do
    describe "status_code" do
      it "uses the default status if none is set" do
        context = build_context
        print_data_response(context, io: fixture_io)

        context.response.status_code.should eq Lucky::TextResponse::DEFAULT_STATUS
      end

      it "uses the passed in status" do
        context = build_context
        print_data_response(context, io: fixture_io, status: 300)

        context.response.status_code.should eq 300
      end

      it "uses the response status if it's set, and Lucky::TextResponse status is nil" do
        context = build_context
        context.response.status_code = 300
        print_data_response(context, io: fixture_io)

        context.response.status_code.should eq 300
      end
    end

    describe "content_type" do
      it "uses the default content_type when no extension is present" do
        context = build_context
        print_data_response(context, io: fixture_io)

        context.response.headers["Content-Type"].should eq "application/octet-stream"
      end

      it "uses the provided content_type" do
        context = build_context
        print_data_response(context, io: fixture_io, content_type: "text/plain")

        context.response.headers["Content-Type"].should eq "text/plain"
      end
    end

    describe "disposition" do
      it "is 'attachment' by default" do
        context = build_context
        print_data_response(context, io: fixture_io)

        context.response.headers["Content-Disposition"].should eq "attachment"
      end

      it "can be changed to 'inline'" do
        context = build_context
        print_data_response(context, io: fixture_io, disposition: "inline")

        context.response.headers["Content-Disposition"].should eq "inline"
      end

      it "can set the downloaded file's name" do
        context = build_context
        print_data_response(context, io: fixture_io, filename: "logo.png")

        context.response.headers["Content-Disposition"].should eq %(attachment; filename="logo.png")
      end
    end
  end
end

private def print_data_response(context : HTTP::Server::Context,
                                io : IO,
                                content_type : String = "application/octet-stream",
                                disposition : String = "attachment",
                                filename : String? = nil,
                                status : Int32? = nil)
  response = Lucky::DataResponse.new(context,
    io,
    content_type,
    disposition: disposition,
    filename: filename,
    status: status)
  response.print
end

private def fixture_io(content : String = "Lucky is awesome")
  IO::Memory.new(content)
end
