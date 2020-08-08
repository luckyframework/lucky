# Configure what types of formats your action responds to
module Lucky::VerifyAcceptsFormat
  abstract def clients_desired_format : Symbol

  macro included
    before verify_accepted_format

    def self._accepted_formats
      [] of Symbol
    end
  end

  # Set the single format that the Action accepts.
  #
  # Same as `accepted_formats` but this one only accepts one format and no
  # default. If you pass an empty array or more than one format, you must
  # use the other `accepted_formats` so you can tell Lucky what the `default`
  # format should be.
  #
  # If something other than the accepted formats are requested, Lucky will raise
  # a `Lucky::NotAcceptableError` error.
  #
  # ```
  # # Default is set to :html since there is just one format
  # accepted_formats [:html]
  #
  # # Raises at compile time because Lucky needs to know which format is the default
  # accepted_formats [:html, :json]
  #
  # # If more than one format is accepted, you must provide the default explicitly
  # accepted_formats [:html, :json], default: :html
  # ```
  macro accepted_formats(formats)
    {% if !formats.is_a?(ArrayLiteral) %}
      {% raise "#{@type} 'accepted_formats' should be an array of Symbols. Example: [:html, :json]" %}
    {% end %}

    {% if formats.size == 1 %}
      accepted_formats {{ formats }}, default: {{ formats.first }}
    {% else %}
      {% formats.raise "#{@type} must pass a default to 'accepted_formats'. Example: accepted_formats [:html, :json], default: :html" %}
    {% end %}
  end

  # Set what formats the Action accepts.
  #
  # If something other than the accepted formats are requested, Lucky will raise
  # a `Lucky::NotAcceptableError` error.
  #
  # ```
  # accepted_formats [:html, :json], default: :json
  # ```
  macro accepted_formats(formats, default)
    {% if !formats.is_a?(ArrayLiteral) %}
      {% formats.raise "#{@type} 'accepted_formats' should be an array of Symbols. Example: [:html, :json]" %}
    {% end %}

    {% if !default.is_a?(SymbolLiteral) %}
      {% formats.raise "#{@type} default format should be a symbol. Example: :html" %}
    {% end %}

    def self._accepted_formats
      {{ formats }}
    end
    default_format {{ default }}
  end

  private def verify_accepted_format
    verify_all_formats_recognized!

    if all_formats_allowed? || self.class._accepted_formats.includes?(clients_desired_format)
      continue
    else
      raise Lucky::NotAcceptableError.new(
        request: request,
        action_name: self.class.name,
        format: clients_desired_format,
        accepted_formats: self.class._accepted_formats
      )
    end
  end

  private def verify_all_formats_recognized! : Nil
    find_unrecognized_format.try do |unrecognized_format|
      raise <<-TEXT
      #{self.class.name} accepts an unrecognized format :#{unrecognized_format}

      You can teach Lucky how to handle this format:

          # Add this in config/mime_types.cr
          Lucky::MimeType.register "text/custom", :#{unrecognized_format}

      Or use one of these formats Lucky knows about:

          #{Lucky::MimeType.known_formats.join(", ")}


      TEXT
    end
  end

  @_find_unrecognized_format : Symbol?

  private def find_unrecognized_format : Symbol?
    @_find_unrecognized_format ||= self.class._accepted_formats.find do |format|
      !Lucky::MimeType.registered?(format)
    end
  end

  private def all_formats_allowed? : Bool
    self.class._accepted_formats.empty?
  end
end
