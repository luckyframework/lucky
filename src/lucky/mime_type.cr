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
  # It's a JS request, but not JSON, or XML
  register "text/plain", :ajax
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
    accept_header_formats.values.uniq!
  end

  def self.registered?(format : Symbol) : Bool
    known_formats.includes?(format)
  end

  def self.register(accept_header_substring : AcceptHeaderSubstring, format : Format) : Nil
    accept_header_formats[accept_header_substring] = format
  end

  def self.deregister(accept_header_substring : AcceptHeaderSubstring) : Nil
    accept_header_formats.delete(accept_header_substring)
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

  class AcceptList
    getter list

    def initialize(accept : String?)
      if accept && !accept.empty?
        @list = AcceptList.parse(accept)
      else
        @list = [] of MediaRange
      end

    end

    # Parses the value of an Accept header and returns an array of MediaRanges sorted by
    # quality value.
    def self.parse(accept : String) : Array(MediaRange)
      # TODO: consts for Regexes
      # TODO: Catch InvalidMediaRange exception
      list = accept.split(/[ \t]*,[ \t]*/).map { |range| MediaRange.parse(range) }
      list.unstable_sort_by! { |range| -range.qvalue.to_i32 }
    end
  end

  class MediaRange
    TOKEN = /[!#$%&'*+.^_`|~0-9A-Za-z-]+/
    MEDIA_TYPE = /^(#{TOKEN})\/(#{TOKEN})$/

    getter type, subtype, qvalue

    def initialize(type : String, @subtype : String, qvalue : UInt16)
      if type == "*" && @subtype != "*"
        raise "invalid media range" # FIXME
      end
      unless (0..1000).includes?(qvalue)
        raise "invalid media range" # FIXME
      end

      @type = type
      @qvalue = qvalue
    end

    # Parse a single media range with optional parameters
    # https://httpwg.org/specs/rfc9110.html#field.accept
    def self.parse(input : String)
      parameters = input.split(/[ \t]*;[ \t]*/)
        media = parameters.shift

      # For now we're only interested in the weight, which must be the last parameter
      qvalue = MediaRange.parse_qvalue(parameters.last?)

      if media =~ MEDIA_TYPE
        # TODO validate that $1 is not *
        type = $1
        subtype = $2
        MediaRange.new(type.downcase, subtype.downcase, qvalue)
      else
        raise "invalid media type"
      end
    end

    def self.parse_qvalue(parameter : String?) : UInt16
      if parameter && parameter =~ /^[qQ]=([01][0-9.]*)$/
        # qvalues start with 0 or 1 and can have up to three digits after the
        # decimal point. To avoid needing to deal with floats, the value is
        # muliplied by 1000 and then handled as an integer.
        # TODO: Handle ArgumentError and OverflowError
        ($1.to_f32 * 1000).round.to_u16
      else
        1000u16
      end
    end

    def ==(other)
      @type == other.type &&
        @subtype == other.subtype &&
        @qvalue == other.qvalue
    end
  end
end

# TODO: Parse Accept header into AcceptList that has the things sorted by quality factor and handles wild cards
