# :nodoc:
class Lucky::MimeType
  alias Format = Symbol
  alias AcceptHeaderSubstring = String
  class_getter accept_header_formats = {} of AcceptHeaderSubstring => Format

  register "text/html", :html
  register "application/json", :json
  register "text/json", :json
  register "application/jsonrequest", :json
  register "text/javascript", :js
  register "application/xml", :xml
  register "application/rss+xml", :rss
  register "application/atom+xml", :atom
  register "application/x-yaml", :yaml
  register "text/yaml", :yaml
  register "text/csv", :csv
  register "text/css", :css
  register "text/calendar", :ics
  register "text/plain", :plain_text
  register "multipart/form-data", :multipart_form
  register "application/x-www-form-urlencoded", :url_encoded_form

  def self.known_accept_headers : Array(String)
    accept_header_formats.keys
  end

  def self.known_formats : Array(Symbol)
    accept_header_formats.values.uniq
  end

  def self.registered?(format : Symbol) : Bool
    known_formats.includes?(format)
  end

  def self.register(accept_header_substring : AcceptHeaderSubstring, format : Format) : Nil
    accept_header_formats[accept_header_substring] = format
  end

  # :nodoc:
  def self.determine_clients_desired_format(request, default_format : Symbol, accepted_formats : Array(Symbol))
    DetermineClientsDesiredFormat.new(request, default_format, accepted_formats).call
  end

  private class DetermineClientsDesiredFormat
    private getter request, default_format, accepted_formats

    def initialize(@request : HTTP::Request, @default_format : Symbol, @accepted_formats : Array(Symbol))
    end

    def call : Symbol?
      accept = accept_header

      if usable_accept_header? && accept
        from_accept_header(accept)
      elsif accepts_html? && default_accept_header_that_browsers_send?
        :html
      else
        default_format
      end
    end

    private def accepts_html? : Bool
      @accepted_formats.includes? :html
    end

    private def from_accept_header(accept : String) : Symbol?
      # If the request accepts anything with no particular preference, return
      # the default format
      if accept == "*/*"
        default_format
      else
        Lucky::MimeType.accept_header_formats.find do |accept_header_substring, _format|
          accept.includes?(accept_header_substring)
        end.try(&.[1])
      end
    end

    private def usable_accept_header? : Bool
      !!(accept_header && !default_accept_header_that_browsers_send?)
    end

    private def accept_header : String?
      accept = request.headers["Accept"]?

      if accept && !accept.empty?
        accept
      end
    end

    # This checks if the "Accept" header is from a browser. Browsers typically
    # include "*/*" along with other characters in the request's "Accept" header.
    # This method handles those intricacies and determines if the header is from
    # a browser.
    private def default_accept_header_that_browsers_send? : Bool
      accept = accept_header

      !!accept && !!(accept =~ /,\s*\*\/\*|\*\/\*\s*,/)
    end
  end
end
