require "../spec_helper"

include ContextHelper

describe Lucky::MimeType do
  describe "determine_clients_desired_format" do
    it "returns the format for the 'Accept' header" do
      format = determine_format("accept": "application/json", "X-Requested-With": "XmlHttpRequest")
      format.should eq(:json)
    end

    it "returns the format for the 'Accept' header if it is not the default browser header " do
      format = determine_format("accept": "application/json")
      format.should eq(:json)
    end

    it "returns 'nil' if there is a non-browser 'Accept' header, but Lucky doesn't understand it" do
      format = determine_format("accept": "wut/is-this")
      format.should be_nil
    end

    it "returns the 'default_format' if the 'Accept' header accepts anything '*/*'" do
      format = determine_format(default_format: :csv, "accept": "*/*")
      format.should eq(:csv)
    end

    describe "when the 'Accept' header is the default browser header" do
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

    it "falls back to 'default_format' if no accept header" do
      format = determine_format(default_format: :csv)
      format.should eq(:csv)
    end

    describe "when the 'Accept' header accepts all images" do
      before_each do
        Lucky::MimeType.register "image/png", :png
        Lucky::MimeType.register "image/x-icon", :ico
      end

      after_each do
        Lucky::MimeType.deregister "image/png"
        Lucky::MimeType.deregister "image/x-icon"
      end

      it "returns the default accepted mime type that matches the prefix" do
        any_image = "image/*;q=0.8"
        format = determine_format(default_format: :ico, headers: {"accept": any_image}, accepted_formats: [:png, :ico])
        format.should eq(:png)
      end
    end

    describe "when the 'Accept' header accepts anything with a lower quality factor" do
      # Test for https://github.com/luckyframework/lucky/issues/1766
      it "returns an accepted format" do
        accept = "*/*; q=0.5, application/xml"
        format = determine_format(default_format: :html, headers: {"accept": accept}, accepted_formats: [:json])
        format.should eq(:json)
      end
    end
  end

  describe Lucky::MimeType::MediaRange do
    it "accepts valid values" do
      [
        {"*/*", Lucky::MimeType::MediaRange.new("*", "*", 1000)},
        {"image/*", Lucky::MimeType::MediaRange.new("image", "*", 1000)},
        {"text/plain", Lucky::MimeType::MediaRange.new("text", "plain", 1000)},
      ].each do |test|
        Lucky::MimeType::MediaRange.parse(test[0]).should eq(test[1])
      end
    end

    it "rejects invalid values" do
      [
        {"*/image", "*/image is not a valid media range"},
        {"asdf", "asdf is not a valid media range"},
        {"text/plain; q=1.9", "qvalue 1.9 is not within 0 to 1.0"},
        {"text/plain; q=1.2.3", "1.2.3 is not a valid qvalue"},
      ].each do |range, message|
        expect_raises(Lucky::MimeType::InvalidMediaRange, message) do
          Lucky::MimeType::MediaRange.parse(range)
        end
      end
    end

    it "accepts parameters" do
      expected = Lucky::MimeType::MediaRange.new("text", "plain", 1000)
      [
        "text/plain;format=flowed",
        "text/plain\t; format=flowed",
        "text/plain;format=fixed",
        "text/plain; format=fixed",
        "text/plain \t; \tformat=fixed",
        "text/plain;format=fixed;charset=UTF-8",
      ].each do |input|
        Lucky::MimeType::MediaRange.parse(input).should eq(expected)
      end
    end

    it "ignores case" do
      expected = Lucky::MimeType::MediaRange.new("text", "html", 1000)
      [
        "text/html;charset=utf-8",
        "Text/HTML;Charset=\"utf-8\"",
        "text/html; charset=\"utf-8\"",
        "text/html;charset=UTF-8",
      ].each do |input|
        Lucky::MimeType::MediaRange.parse(input).should eq(expected)
      end
    end

    it "parses the qvalue" do
      [
        {"*/*; q=0", Lucky::MimeType::MediaRange.new("*", "*", 0)},
        {"*/*; q=1", Lucky::MimeType::MediaRange.new("*", "*", 1000)},
        {"*/*; q=0.1", Lucky::MimeType::MediaRange.new("*", "*", 100)},
        {"image/*; q=0.12", Lucky::MimeType::MediaRange.new("image", "*", 120)},
        {"text/plain; q=0.123", Lucky::MimeType::MediaRange.new("text", "plain", 123)},
        {"text/plain;format=fixed;q=0.4", Lucky::MimeType::MediaRange.new("text", "plain", 400)},
        # qvalue must be last so is ignored if not
        {"text/plain;q=0.4;format=fixed", Lucky::MimeType::MediaRange.new("text", "plain", 1000)},
      ].each do |test|
        Lucky::MimeType::MediaRange.parse(test[0]).should eq(test[1])
      end
    end
  end

  describe Lucky::MimeType::AcceptList do
    it "is empty when the Accept value is nil" do
      Lucky::MimeType::AcceptList.new(nil).list.should be_empty
    end

    it "accepts single values" do
      expected = [Lucky::MimeType::MediaRange.new("text", "html", 1000)]
      Lucky::MimeType::AcceptList.new("text/html").list.should eq(expected)
    end

    it "accepts multiple values" do
      expected = [
        Lucky::MimeType::MediaRange.new("audio", "basic", 1000),
        Lucky::MimeType::MediaRange.new("audio", "*", 200),
      ]
      Lucky::MimeType::AcceptList.new("audio/*; q=0.2, audio/basic").list.should eq(expected)
    end

    it "sorts multiple values by qvalue" do
      expected = [
        Lucky::MimeType::MediaRange.new("text", "html", 1000),
        Lucky::MimeType::MediaRange.new("text", "x-c", 1000),
        Lucky::MimeType::MediaRange.new("text", "x-dvi", 800),
        Lucky::MimeType::MediaRange.new("text", "plain", 500),
      ]
      Lucky::MimeType::AcceptList.new("text/plain; q=0.5, text/html, text/x-dvi; q=0.8, text/x-c").list.should eq(expected)
    end

    it "parses a default browser Accept value" do
      expected = [
        Lucky::MimeType::MediaRange.new("text", "html", 1000),
        Lucky::MimeType::MediaRange.new("application", "xhtml+xml", 1000),
        Lucky::MimeType::MediaRange.new("image", "avif", 1000),
        Lucky::MimeType::MediaRange.new("image", "webp", 1000),
        Lucky::MimeType::MediaRange.new("application", "xml", 900),
        Lucky::MimeType::MediaRange.new("*", "*", 800),
      ]
      # Value is from Firefox requesting a web page
      Lucky::MimeType::AcceptList.new("text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8").list.should eq(expected)
    end

    it "skips invalid media ranges" do
      expected = [
        Lucky::MimeType::MediaRange.new("audio", "basic", 1000),
      ]
      Lucky::MimeType::AcceptList.new("*/invalid; q=0.2, audio/basic").list.should eq(expected)
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
