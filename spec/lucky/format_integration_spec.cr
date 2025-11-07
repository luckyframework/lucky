require "../spec_helper"

include ContextHelper

private class TestReportsAction < TestAction
  accepted_formats [:html, :json, :csv], default: :html

  get "/reports/:id" do
    case clients_desired_format
    when :html
      plain_text "HTML Report for #{id}"
    when :json
      plain_text %({"report_id": "#{id}", "format": "json"})
    when :csv
      plain_text "id,name\n#{id},Test Report"
    else
      plain_text "Unknown format"
    end
  end
end

describe "Format Integration", focus: true do
  it "handles URL format extensions correctly" do
    # Test CSV format from URL extension
    context = build_context(path: "/reports/123.csv")

    # The route handler should extract the format and strip it for route matching
    Lucky::RouteHandler.new.call(context)

    # Verify the format was extracted
    context._url_format.should eq(Lucky::Format::Csv)
  end

  it "routes correctly with format stripped from path" do
    # Test that /reports/123.csv routes to /reports/:id
    context = build_context(path: "/reports/123.csv")

    # Manually set the URL format as the route handler would
    context._url_format = Lucky::Format::Csv

    action = TestReportsAction.new(context, {"id" => "123"})

    # Should detect CSV format from URL
    action.accepts?(:csv).should be_true
    action.accepts?(:html).should be_false
  end

  it "falls back to Accept header when no URL format" do
    context = build_context(path: "/reports/123")
    context.request.headers["Accept"] = "application/json"
    action = TestReportsAction.new(context, {"id" => "123"})

    # Should detect JSON format from Accept header
    action.accepts?(:json).should be_true
    action.accepts?(:csv).should be_false
  end

  # testing https://github.com/luckyframework/lucky/issues/1999
  it "handles other routes properly" do
    context = build_context(path: "/js/main.js")
    handler = Lucky::RouteHandler.new.call(context)
    handler.should eq(nil)

    context = build_context(path: "/reports/main.js")
    expect_raises Lucky::NotAcceptableError do
      Lucky::RouteHandler.new.call(context)
    end
  end

  it "supports multiple format extensions" do
    Lucky::MimeType.extract_format_from_path("/reports/123.html").should eq(Lucky::Format::Html)
    Lucky::MimeType.extract_format_from_path("/users/456.json").should eq(Lucky::Format::Json)
    Lucky::MimeType.extract_format_from_path("/data/export.xml").should eq(Lucky::Format::Xml)
    Lucky::MimeType.extract_format_from_path("/styles/main.css").should eq(Lucky::Format::Css)
  end
end
