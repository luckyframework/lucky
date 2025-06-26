require "../spec_helper"

include ContextHelper

private class FakeActionWithFormat
  include Lucky::RequestTypeHelpers
  default_format :html

  property context : HTTP::Server::Context = ContextHelper.build_context
  class_property _accepted_formats = [:html, :json, :csv, :xml] of Symbol

  delegate request, to: context
end

describe "URL Format Detection" do
  it "extracts format from URL path" do
    Lucky::MimeType.extract_format_from_path("/reports/123.csv").should eq Lucky::Format::Csv
    Lucky::MimeType.extract_format_from_path("/reports/123.json").should eq Lucky::Format::Json
    Lucky::MimeType.extract_format_from_path("/reports/123.xml").should eq Lucky::Format::Xml
    Lucky::MimeType.extract_format_from_path("/reports/123.html").should eq Lucky::Format::Html
  end

  it "returns nil for unknown formats" do
    Lucky::MimeType.extract_format_from_path("/reports/123.unknown").should be_nil
    Lucky::MimeType.extract_format_from_path("/reports/123").should be_nil
  end

  it "handles query parameters correctly" do
    Lucky::MimeType.extract_format_from_path("/reports/123.csv?param=value").should eq Lucky::Format::Csv
    Lucky::MimeType.extract_format_from_path("/reports/123.json?foo=bar&baz=qux").should eq Lucky::Format::Json
  end

  it "uses URL format over Accept header" do
    context = build_context
    context.request.headers["Accept"] = "application/json"
    context._url_format = Lucky::Format::Csv
    
    action = FakeActionWithFormat.new
    action.context = context
    action.accepts?(:csv).should be_true
    action.accepts?(:json).should be_false
  end

  it "falls back to Accept header when no URL format" do
    context = build_context
    context.request.headers["Accept"] = "application/json"
    # Don't set _url_format, should fallback to Accept header
    
    action = FakeActionWithFormat.new
    action.context = context
    action.accepts?(:json).should be_true
    action.accepts?(:csv).should be_false
  end
end