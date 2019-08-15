require "../spec_helper"

include ContextHelper

describe Lucky::MimeType do
  describe "known_formats" do
    it "returns :html even though there is no mapping" do
      Lucky::MimeType.known_formats.should contain(:html)
    end
  end

  describe "determine_clients_desired_format" do
    it "returns the format for the 'Accept' header if it is an AJAX request" do
      format = determine_format("accept": "application/json", "X-Requested-With": "XmlHttpRequest")
      format.should eq(:json)
    end

    it "returns the format for the 'Accept' header if it is not the default browser header " do
      format = determine_format("accept": "application/json")
      format.should eq(:json)
    end

    it "returns :ajax if it is an AJAX request and no 'Accept' header is given" do
      format = determine_format("X-Requested-With": "XmlHttpRequest")
      format.should eq(:ajax)
    end

    describe "when the 'Accept' header is the default browser header, and it is not an AJAX request" do
      it "returns :html if :html is an accepted format" do
        default_browser_header = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        format = determine_format(default_format: :csv, headers: {"accept": default_browser_header}, accepted_formats: [:html, :csv])
        format.should eq(:html)
      end

      it "returns the 'default_format' if :html is NOT an accepted format" do
        default_browser_header = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        format = determine_format(default_format: :csv, "accept": default_browser_header)
        format.should eq(:csv)
      end
    end

    it "falls back to 'default_format' if no accept header and not AJAX" do
      format = determine_format(default_format: :csv)
      format.should eq(:csv)
    end
  end
end

private def determine_format(default_format = :ics, **headers)
  determine_format(default_format, headers, accepted_formats: [] of Symbol)
end

private def determine_format(default_format, headers, accepted_formats)
  headers = headers.to_h.transform_keys(&.to_s.as(String))
  request = build_request
  request.headers.merge!(headers)
  Lucky::MimeType.determine_clients_desired_format(
    request,
    default_format: default_format,
    accepted_formats: accepted_formats
  )
end
