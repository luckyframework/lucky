require "../spec_helper"

include ContextHelper

describe Lucky::FileResponse do
  describe "#print" do
    describe "status_code" do
      it "uses the default status if none is set" do
        context = build_context
        print_data_response(context)

        context.response.status_code.should eq Lucky::TextResponse::DEFAULT_STATUS
      end

      it "uses the passed in status" do
        context = build_context
        print_data_response(context, status: 300)

        context.response.status_code.should eq 300
      end

      it "uses the response status if it's set, and Lucky::TextResponse status is nil" do
        context = build_context
        context.response.status_code = 300
        print_data_response(context)

        context.response.status_code.should eq 300
      end
    end

    describe "content_length" do
      it "calculates from a bytesize of the data" do
        context = build_context
        data = "Lucky is awesome 🤟"
        print_data_response(context, data: data)

        context.response.headers["Content-Length"].should eq data.bytesize.to_s
      end
    end

    describe "content_type" do
      it "uses the default content_type when no extension is present" do
        context = build_context
        print_data_response(context)

        context.response.headers["Content-Type"].should eq "application/octet-stream"
      end

      it "uses the provided content_type" do
        context = build_context
        print_data_response(context, content_type: "text/plain")

        context.response.headers["Content-Type"].should eq "text/plain"
      end
    end

    describe "disposition" do
      it "is 'attachment' by default" do
        context = build_context
        print_data_response(context)

        context.response.headers["Content-Disposition"].should eq "attachment"
      end

      it "can be changed to 'inline'" do
        context = build_context
        print_data_response(context, disposition: "inline")

        context.response.headers["Content-Disposition"].should eq "inline"
      end

      it "can set the downloaded file's name" do
        context = build_context
        print_data_response(context, filename: "logo.png")

        context.response.headers["Content-Disposition"].should eq %(attachment; filename="logo.png")
      end
    end
  end
end

private def print_data_response(context : HTTP::Server::Context,
                                data : String = "Lucky is awesome",
                                content_type : String = "application/octet-stream",
                                disposition : String = "attachment",
                                filename : String? = nil,
                                status : Int32? = nil)
  response = Lucky::DataResponse.new(context,
    data,
    content_type,
    disposition: disposition,
    filename: filename,
    status: status)
  response.print
end
