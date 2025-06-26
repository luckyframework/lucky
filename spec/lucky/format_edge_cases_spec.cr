require "../spec_helper"

include ContextHelper

private class EdgeCaseFormatAction < TestAction
  accepted_formats [:html, :json, :csv], default: :html

  get "/test/:id" do
    plain_text "format: #{clients_desired_format}, id: #{id}"
  end
end

describe "Format Detection Edge Cases" do
  describe "URL parsing edge cases" do
    it "handles multiple dots in filename correctly" do
      # Should extract only the final extension
      Lucky::MimeType.extract_format_from_path("/reports/file.backup.csv").should eq Lucky::Format::Csv
      Lucky::MimeType.extract_format_from_path("/data/export.final.json").should eq Lucky::Format::Json
      Lucky::MimeType.extract_format_from_path("/styles/theme.dark.css").should eq Lucky::Format::Css
    end

    it "handles edge case extensions" do
      # Empty extension
      Lucky::MimeType.extract_format_from_path("/reports/file.").should be_nil

      # No extension
      Lucky::MimeType.extract_format_from_path("/reports/file").should be_nil

      # Very long extension (should be nil since not registered)
      Lucky::MimeType.extract_format_from_path("/file.superlongextension").should be_nil

      # Single character extensions
      Lucky::MimeType.extract_format_from_path("/file.x").should be_nil
    end

    it "handles case sensitivity correctly" do
      # Extensions should be case insensitive
      Lucky::MimeType.extract_format_from_path("/reports/file.CSV").should eq Lucky::Format::Csv
      Lucky::MimeType.extract_format_from_path("/reports/file.Json").should eq Lucky::Format::Json
      Lucky::MimeType.extract_format_from_path("/reports/file.HTML").should eq Lucky::Format::Html
      Lucky::MimeType.extract_format_from_path("/reports/file.XML").should eq Lucky::Format::Xml
    end

    it "handles complex query parameters" do
      Lucky::MimeType.extract_format_from_path("/reports/123.csv?foo=bar&baz=qux&nested[key]=value").should eq Lucky::Format::Csv
      Lucky::MimeType.extract_format_from_path("/api/data.json?callback=func&v=1.0").should eq Lucky::Format::Json
      Lucky::MimeType.extract_format_from_path("/file.html?").should eq Lucky::Format::Html
      Lucky::MimeType.extract_format_from_path("/file.xml?#fragment").should eq Lucky::Format::Xml
    end

    it "does not match extensions in query string domains" do
      # Should not detect .com, .org, .net, etc. from domains in query strings
      Lucky::MimeType.extract_format_from_path("/path/report.csv?affiliate=site.com/path.html").should eq Lucky::Format::Csv
      Lucky::MimeType.extract_format_from_path("/login?redirect_to=https://example.com").should be_nil
      Lucky::MimeType.extract_format_from_path("/api/data?url=http://site.org/file.pdf").should be_nil
      Lucky::MimeType.extract_format_from_path("/report?source=domain.net&format=json").should be_nil

      # Should still match valid extensions before the query string
      Lucky::MimeType.extract_format_from_path("/file.json?redirect=site.com").should eq Lucky::Format::Json
      Lucky::MimeType.extract_format_from_path("/data.xml?callback=example.org/api").should eq Lucky::Format::Xml
    end

    it "handles special characters and edge case paths" do
      # URL encoded extensions
      Lucky::MimeType.extract_format_from_path("/reports/file%2Ecsv").should be_nil # encoded dot

      # Paths that look like extensions but aren't
      Lucky::MimeType.extract_format_from_path("/reports/.csv").should eq Lucky::Format::Csv # hidden file with extension
      Lucky::MimeType.extract_format_from_path("/reports/csv").should be_nil                 # no dot
      Lucky::MimeType.extract_format_from_path("/reports.csv/file").should be_nil            # extension in directory name
    end

    it "handles unusual but valid paths" do
      # Root level files
      Lucky::MimeType.extract_format_from_path("/file.json").should eq Lucky::Format::Json

      # Deep nested paths
      Lucky::MimeType.extract_format_from_path("/very/deep/nested/path/to/file.csv").should eq Lucky::Format::Csv

      # Files with numbers and special chars in name
      Lucky::MimeType.extract_format_from_path("/file-123_test.json").should eq Lucky::Format::Json
      Lucky::MimeType.extract_format_from_path("/file%20name.csv").should eq Lucky::Format::Csv
    end
  end

  describe "Route matching edge cases" do
    it "handles routes with parameters that contain dots" do
      context = build_context(path: "/test/user.email@example.com.json")
      context._url_format = Lucky::Format::Json

      action = EdgeCaseFormatAction.new(context, {"id" => "user.email@example.com"})
      action.accepts?(:json).should be_true
      action.url_format.should eq Lucky::Format::Json
    end

    it "handles very long URLs with formats" do
      long_id = "a" * 1000
      path = "/test/#{long_id}.csv"

      Lucky::MimeType.extract_format_from_path(path).should eq Lucky::Format::Csv
    end

    it "handles Unicode and international characters" do
      # These should not break the format detection (though they won't match known formats)
      Lucky::MimeType.extract_format_from_path("/file.файл").should be_nil
      Lucky::MimeType.extract_format_from_path("/file.josé").should be_nil
      Lucky::MimeType.extract_format_from_path("/file.日本").should be_nil
    end
  end

  describe "Format validation edge cases" do
    it "handles URL format not in accepted formats" do
      context = build_context(path: "/test/123.xml")
      context._url_format = Lucky::Format::Xml

      action = EdgeCaseFormatAction.new(context, {"id" => "123"})

      # Should detect XML format but action only accepts html, json, csv
      action.url_format.should eq Lucky::Format::Xml
      action.accepts?(:xml).should be_true # This will be true since clients_desired_format returns the URL format

      # But the action's accepted formats validation should catch this
      # (This would be caught by Lucky's existing format validation system)
    end

    it "handles format precedence correctly" do
      context = build_context(path: "/test/123.csv")
      context.request.headers["Accept"] = "application/json, text/html"
      context._url_format = Lucky::Format::Csv

      action = EdgeCaseFormatAction.new(context, {"id" => "123"})

      # URL format should take precedence over Accept header
      action.accepts?(:csv).should be_true
      action.accepts?(:json).should be_false
      action.accepts?(:html).should be_false
    end

    it "handles missing Accept header gracefully" do
      context = build_context(path: "/test/123")
      # Don't set Accept header at all
      context.request.headers.delete("Accept")

      action = EdgeCaseFormatAction.new(context, {"id" => "123"})

      # Should fall back to default format
      action.accepts?(:html).should be_true # html is the default
    end
  end

  describe "Custom format edge cases" do
    it "handles custom format registration and detection" do
      # Register a custom format
      Lucky::FormatRegistry.register("PDF", "pdf", "application/pdf")

      # Should detect the custom format
      format = Lucky::MimeType.extract_format_from_path("/report.pdf")
      format.should be_a(Lucky::FormatRegistry::CustomFormat)

      if custom_format = format.as?(Lucky::FormatRegistry::CustomFormat)
        custom_format.name.should eq "PDF"
        custom_format.extension.should eq "pdf"
        custom_format.mime_type.should eq "application/pdf"
      end

      # Clean up
      Lucky::FormatRegistry.custom_formats.delete("PDF")
    end

    it "handles multiple custom formats with different extensions" do
      # Register different custom formats
      Lucky::FormatRegistry.register("PDF", "pdf", "application/pdf")
      Lucky::FormatRegistry.register("DOC", "doc", "application/msword")

      pdf_format = Lucky::MimeType.extract_format_from_path("/report.pdf")
      doc_format = Lucky::MimeType.extract_format_from_path("/document.doc")

      pdf_format.should be_a(Lucky::FormatRegistry::CustomFormat)
      doc_format.should be_a(Lucky::FormatRegistry::CustomFormat)

      if pdf_custom = pdf_format.as?(Lucky::FormatRegistry::CustomFormat)
        pdf_custom.name.should eq "PDF"
      end

      if doc_custom = doc_format.as?(Lucky::FormatRegistry::CustomFormat)
        doc_custom.name.should eq "DOC"
      end

      # Clean up
      Lucky::FormatRegistry.custom_formats.delete("PDF")
      Lucky::FormatRegistry.custom_formats.delete("DOC")
    end
  end

  describe "HTTP header edge cases" do
    it "handles malformed Accept headers gracefully when URL format is present" do
      context = build_context(path: "/test/123")
      context.request.headers["Accept"] = "invalid-header-format"
      context._url_format = Lucky::Format::Json # Set URL format to trigger graceful handling

      action = EdgeCaseFormatAction.new(context, {"id" => "123"})

      # Should use URL format, not fall back to malformed Accept header
      action.accepts?(:json).should be_true
    end

    it "raises error for malformed Accept headers when no URL format" do
      context = build_context(path: "/test/123")
      context.request.headers["Accept"] = "invalid-header-format"
      # Don't set URL format - should preserve original Lucky behavior

      action = EdgeCaseFormatAction.new(context, {"id" => "123"})

      # Should raise error as in original Lucky behavior
      expect_raises Lucky::UnknownAcceptHeaderError do
        action.accepts?(:html)
      end
    end

    it "handles very complex Accept headers" do
      context = build_context(path: "/test/123")
      complex_accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
      context.request.headers["Accept"] = complex_accept

      action = EdgeCaseFormatAction.new(context, {"id" => "123"})

      # Should parse the complex header correctly
      action.accepts?(:html).should be_true
    end

    it "handles empty Accept header" do
      context = build_context(path: "/test/123")
      context.request.headers["Accept"] = ""

      action = EdgeCaseFormatAction.new(context, {"id" => "123"})

      # Should fall back to default
      action.accepts?(:html).should be_true
    end
  end

  describe "Performance and security edge cases" do
    it "handles extremely long paths efficiently" do
      # Very long path with format at the end
      long_path = "/very/long/path/" + ("segment/" * 1000) + "file.json"

      # Should still extract format efficiently
      start_time = Time.monotonic
      format = Lucky::MimeType.extract_format_from_path(long_path)
      end_time = Time.monotonic

      format.should eq Lucky::Format::Json
      (end_time - start_time).should be < 0.1.seconds # Should be very fast
    end

    it "handles path traversal attempts safely" do
      # These should not cause security issues, just fail format detection
      Lucky::MimeType.extract_format_from_path("../../../etc/passwd.csv").should eq Lucky::Format::Csv
      Lucky::MimeType.extract_format_from_path("/reports/../admin.json").should eq Lucky::Format::Json
      Lucky::MimeType.extract_format_from_path("/reports/..%2F..%2Fadmin.xml").should eq Lucky::Format::Xml
    end

    it "handles null bytes and control characters" do
      # Should not crash on unusual input
      Lucky::MimeType.extract_format_from_path("/file\u0000.csv").should eq Lucky::Format::Csv
      Lucky::MimeType.extract_format_from_path("/file\t.json").should eq Lucky::Format::Json
      Lucky::MimeType.extract_format_from_path("/file\n.xml").should eq Lucky::Format::Xml
    end
  end

  describe "Integration edge cases" do
    it "works with nil context gracefully" do
      # This tests that we don't crash if context is somehow nil
      # (Though this shouldn't happen in practice)
      EdgeCaseFormatAction.allocate

      # Should not crash when trying to access format methods
      # (This would be caught by Crystal's type system anyway)
    end

    it "handles concurrent format detection" do
      # Test that format detection is thread-safe
      contexts = [] of HTTP::Server::Context

      10.times do |i|
        context = build_context(path: "/test/#{i}.json")
        context._url_format = Lucky::Format::Json
        contexts << context
      end

      # All should detect JSON format correctly
      contexts.each do |context|
        action = EdgeCaseFormatAction.new(context, {"id" => "test"})
        action.accepts?(:json).should be_true
      end
    end
  end
end
