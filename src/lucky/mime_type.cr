# :nodoc:
class Lucky::MimeType
  alias Format = Symbol
  alias AcceptHeaderSubstring = String
  class_getter accept_header_formats = {} of MediaType => Format

  struct MediaType
    property type, subtype

    def initialize(@type : String, @subtype : String)
    end

    def to_s
      "#{type}/#{subtype}"
    end
  end

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
    accept_header_formats.keys.map(&.to_s)
  end

  def self.known_formats : Array(Symbol)
    accept_header_formats.values.uniq!
  end

  def self.registered?(format : Symbol) : Bool
    known_formats.includes?(format)
  end

  def self.register(accept_header_substring : AcceptHeaderSubstring, format : Format) : Nil
    type, subtype = accept_header_substring.split("/", 2)
    if type && subtype
      accept_header_formats[MediaType.new(type, subtype)] = format
    else
      raise "#{accept_header_substring} is not a valid media type"
    end
  end

  def self.deregister(accept_header_substring : AcceptHeaderSubstring) : Nil
    type, subtype = accept_header_substring.split("/", 2)
    accept_header_formats.delete({type, subtype})
  end

  # :nodoc:
  def self.determine_clients_desired_format(request, default_format : Symbol, accepted_formats : Array(Symbol))
    DetermineClientsDesiredFormat.new(request, default_format, accepted_formats).call
  end

  class InvalidMediaRange < Exception
  end

  private class DetermineClientsDesiredFormat
    private getter request, default_format, accepted_formats

    def initialize(@request : HTTP::Request, @default_format : Symbol, @accepted_formats : Array(Symbol))
    end

    def call : Symbol?
      if accept = accept_header
        from_accept_header(accept)
      else
        default_format
      end
    end

    private def from_accept_header(accept : String) : Symbol?
      # If the request accepts anything with no particular preference, return
      # the default format
      if accept == "*/*"
        default_format
      else
        accept_list = AcceptList.new(accept_header)
        accept_list.find_match(Lucky::MimeType.accept_header_formats, accepted_formats, default_format)
      end
    end

    private def accept_header : String?
      accept = request.headers["Accept"]?

      if accept && !accept.empty?
        accept
      end
    end
  end

  class AcceptList
    getter list

    ACCEPT_SEP = /[ \t]*,[ \t]*/

    # Parses the value of an Accept header and returns an array of MediaRanges sorted by
    # quality value.
    def self.parse(accept : String) : Array(MediaRange)
      list = accept.split(ACCEPT_SEP).compact_map do |range|
        begin
          MediaRange.parse(range)
        rescue ex : InvalidMediaRange
          Log.debug { "invalid media range in Accept: #{accept} - #{ex}" }
          nil
        end
      end
      list.unstable_sort_by! { |range| -range.qvalue.to_i32 }
    end

    def initialize(accept : String?)
      if accept && !accept.empty?
        @list = AcceptList.parse(accept)
      else
        @list = [] of MediaRange
      end
    end

    # Find a matching accepted format by accept list priority
    def find_match(known_formats : Hash(MediaType, Format), accepted_formats : Array(Symbol), default_format : Symbol) : Symbol?
      # If we find a match in the things we accept then pick one of those
      formats_in_common = known_formats.select { |_media, format| accepted_formats.includes?(format) }
      unless formats_in_common.empty?
        self.list.each do |media_range|
          if match = formats_in_common.find { |media, _format| media_range.matches?(media) }
            return match[1]
          end
        end
      end

      # Otherwise if the client doesn't just accept anything then try to find something they
      # do accept in the list of known formats
      unless includes_catch_all?
        self.list.each do |media_range|
          if match = known_formats.find { |media, _format| media_range.matches?(media) }
            return match[1]
          end
        end

        # No known formats match the ones requested
        return nil
      end

      # Finally the client accepts anything so use the default format
      default_format
    end

    def includes_catch_all?
      @list.any? &.catch_all?
    end
  end

  class MediaRange
    TOKEN      = /[!#$%&'*+.^_`|~0-9A-Za-z-]+/
    MEDIA_TYPE = /^(#{TOKEN})\/(#{TOKEN})$/
    PARAM_SEP  = /[ \t]*;[ \t]*/
    QVALUE_RE  = /^[qQ]=([01][0-9.]*)$/

    getter type, subtype, qvalue

    def initialize(type : String, @subtype : String, qvalue : UInt16)
      if type == "*" && @subtype != "*"
        raise InvalidMediaRange.new("#{type}/#{@subtype} is not a valid media range")
      end
      unless (0..1000).includes?(qvalue)
        raise InvalidMediaRange.new("qvalue #{qvalue.to_f32 / 1000f32} is not within 0 to 1.0")
      end

      @type = type
      @qvalue = qvalue
    end

    # Parse a single media range with optional parameters
    # https://httpwg.org/specs/rfc9110.html#field.accept
    def self.parse(input : String)
      parameters = input.split(PARAM_SEP)
      media = parameters.shift

      # For now we're only interested in the weight, which must be the last parameter
      qvalue = MediaRange.parse_qvalue(parameters.last?)

      if media =~ MEDIA_TYPE
        type = $1
        subtype = $2
        MediaRange.new(type.downcase, subtype.downcase, qvalue)
      else
        raise InvalidMediaRange.new("#{input} is not a valid media range")
      end
    end

    def self.parse_qvalue(parameter : String?) : UInt16
      if parameter && parameter =~ QVALUE_RE
        # qvalues start with 0 or 1 and can have up to three digits after the
        # decimal point. To avoid needing to deal with floats, the value is
        # muliplied by 1000 and then handled as an integer.
        begin
          ($1.to_f32 * 1000).round.to_u16
        rescue ArgumentError | OverflowError
          raise InvalidMediaRange.new("#{parameter} is not a valid qvalue")
        end
      else
        1000u16
      end
    end

    def ==(other)
      @type == other.type &&
        @subtype == other.subtype &&
        @qvalue == other.qvalue
    end

    def matches?(media : MediaType) : Bool
      @type == "*" || (@type == media.type && self.class.match_type?(@subtype, media.subtype))
    end

    def catch_all?
      @type == "*" && @subtype == "*"
    end

    protected def self.match_type?(pattern, value)
      pattern == "*" || pattern == value
    end
  end
end
