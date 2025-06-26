# These helpers check HTTP headers to determine "request MIME type".
#
# Generally the `Accept` header is checked, but some check other headers, such as `X-Requested-With`.
module Lucky::RequestTypeHelpers
  private def default_format
    {% raise <<-TEXT
    Must set 'accepted_formats' or 'default_format' in #{@type} (or its parent class).

    Example of 'accepted_formats' (recommended):

      abstract class MyBaseAction < Lucky::Action
        accepted_formats [:html, :json], default: :html
      end

    Example of 'default_format' (typically used only in Errors::Show):

      class Errors::Show < Lucky::ErrorAction
        default_format :html
      end


    TEXT
    %}
  end

  # If Lucky doesn't find a format then default to the given format
  #
  # ```
  # default_format :html
  # ```
  macro default_format(format)
    private def default_format : Symbol
      {{ format }}
    end
  end

  private def clients_desired_format : Symbol
    context._clients_desired_format ||= determine_clients_desired_format
  end

  private def determine_clients_desired_format : Symbol
    # Check URL format first (e.g., /reports/123.csv)
    if url_format = context._url_format
      convert_url_format_to_symbol(url_format)
    else
      # No URL format - use original Lucky behavior (raise on unknown Accept header)
      # This preserves existing error handling behavior when no URL format override exists
      Lucky::MimeType.determine_clients_desired_format(request, default_format, self.class._accepted_formats) ||
        raise Lucky::UnknownAcceptHeaderError.new(request)
    end
  end

  private def convert_url_format_to_symbol(url_format : Lucky::Format | Lucky::FormatRegistry::CustomFormat) : Symbol
    case url_format
    when Lucky::Format
      convert_enum_format_to_symbol(url_format)
    when Lucky::FormatRegistry::CustomFormat
      convert_custom_format_to_symbol(url_format)
    else
      # Fallback to Accept header if URL format is somehow invalid
      # Since URL format failed, gracefully handle Accept header errors too
      determine_format_from_accept_header_with_fallback
    end
  end

  private def convert_enum_format_to_symbol(format : Lucky::Format) : Symbol
    case format
    in .html?             then :html
    in .json?             then :json
    in .xml?              then :xml
    in .csv?              then :csv
    in .js?               then :js
    in .plain_text?       then :plain_text
    in .yaml?             then :yaml
    in .rss?              then :rss
    in .atom?             then :atom
    in .ics?              then :ics
    in .css?              then :css
    in .ajax?             then :ajax
    in .multipart_form?   then :multipart_form
    in .url_encoded_form? then :url_encoded_form
    end
  end

  private def convert_custom_format_to_symbol(format : Lucky::FormatRegistry::CustomFormat) : Symbol
    # For custom formats, we need to manually handle the symbol creation
    # Since Crystal doesn't have dynamic symbol creation, we'll use a macro or fallback
    name = format.name.underscore.tr("-", "_")
    case name
    when "pdf"  then :pdf
    when "zip"  then :zip
    when "doc"  then :doc
    when "docx" then :docx
    when "xls"  then :xls
    when "xlsx" then :xlsx
    when "ppt"  then :ppt
    when "pptx" then :pptx
    else
      # If we can't convert to a known symbol, fall back to default behavior
      # But since we have a URL format, gracefully handle Accept header errors
      determine_format_from_accept_header_with_fallback
    end
  end

  private def determine_format_from_accept_header_with_fallback : Symbol
    Lucky::MimeType.determine_clients_desired_format(request, default_format, self.class._accepted_formats) ||
      raise Lucky::UnknownAcceptHeaderError.new(request)
  rescue Lucky::UnknownAcceptHeaderError
    default_format
  end

  # Check whether the request wants the passed in format
  def accepts?(format : Symbol) : Bool
    clients_desired_format == format
  end

  # Get the detected format as an enum (if available)
  # Returns nil if the format came from Accept header or is unknown
  def url_format : Lucky::Format | Lucky::FormatRegistry::CustomFormat | Nil
    context._url_format
  end

  # Check if the request is JSON
  #
  # This tests if the request type is `application/json`
  def json? : Bool
    accepts?(:json)
  end

  # Check if the request is HTML
  #
  # Browsers typically send vague Accept headers. Because of that this will return `true` when:
  #
  #  * The `accepted_formats` includes `:html`
  #  * And the `Accept` header is the browser default. For example `text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
  def html? : Bool
    accepts?(:html)
  end

  # Check if the request is XML
  #
  # This tests if the request type is `application/xml`
  def xml? : Bool
    accepts?(:xml)
  end

  # Check if the request is plain text
  #
  # This tests if the `Accept` header type is `text/plain` or
  # with the optional character set per W3 RFC1341 7.1
  def plain_text? : Bool
    accepts?(:plain_text)
  end

  # Check if the request is AJAX
  #
  # This tests if the `X-Requested-With` header is `XMLHttpRequest`
  def ajax? : Bool
    request.headers["X-Requested-With"]?.try(&.downcase) == "xmlhttprequest"
  end

  # Check if the request is multipart
  #
  # This tests if the `Content-Type` header is `multipart/form-data`
  def multipart? : Bool
    !!request.headers["Content-Type"]?.try(&.downcase.starts_with?("multipart/form-data"))
  end
end
