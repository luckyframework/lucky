module Lucky
  # = Lucky Errors
  #
  # Generic Lucky Record exception class.
  class Error < Exception
  end

  # Raised when a route could not be found
  class RouteNotFoundError < Error
    getter context

    def initialize(@context : HTTP::Server::Context)
      super "Could not find route matching #{@context.request.method} #{@context.request.path}"
    end
  end

  class ParamParsingError < Error
    include Lucky::RenderableError

    getter request

    def initialize(@request : HTTP::Request)
      super "Failed to parse the request parameters."
    end

    def renderable_status
      400
    end

    def renderable_message
      "There was a problem parsing the JSON params. Please check that it is formed correctly."
    end
  end

  class UnknownAcceptHeaderError < Error
    include Lucky::RenderableError

    getter request

    def initialize(@request : HTTP::Request)
      accept_header = request.headers["accept"]?
      super <<-TEXT
      Lucky couldn't figure out what format the client accepts.

          The client's Accept header: '#{accept_header}'

      You can teach Lucky how to handle this header:

          # Add this in config/mime_types.cr
          Lucky::MimeType.register "#{accept_header}", :custom_format

      Or use one of these headers Lucky knows about:

          #{Lucky::MimeType.known_accept_headers.join(", ")}


      TEXT
    end

    def renderable_status
      406
    end

    def renderable_message
      "Unrecognized Accept header '#{request.headers["Accept"]?}'."
    end
  end

  class NotAcceptableError < Error
    include Lucky::RenderableError

    getter request

    def initialize(action_name : String, format : Symbol, accepted_formats : Array(Symbol))
      super <<-TEXT
      The request wants :#{format}, but #{action_name} does not accept it.

      Accepted formats: #{accepted_formats.map(&.to_s).join(", ")}

      Try this...

        ▸ Add :#{format} to 'accepted_formats' in #{action_name} or its parent class.
        ▸ Make your request using one of the accepted formats.


      TEXT
    end

    def renderable_status
      406
    end

    def renderable_message
      "Accept header '#{request.headers["Accept"]?}' is not accepted."
    end
  end

  # Raised when storing more than 4K of session data.
  class CookieOverflow < Error
  end

  class InvalidSignature < Error
  end

  class InvalidMessage < Error
  end

  class InvalidParam < Error
    include Lucky::RenderableError

    getter :param_name, :param_value, :param_type

    def initialize(@param_name : String, @param_value : String, @param_type : String)
    end

    def message : String?
      "Required param \"#{param_name}\" with value \"#{param_value}\" couldn't be parsed to a \"#{param_type}\""
    end

    def renderable_status : Int32
      HTTP::Status::UNPROCESSABLE_ENTITY.value
    end

    def renderable_message
      "Required param \"#{param_name}\" with value \"#{param_value}\" couldn't be parsed to a \"#{param_type}\""
    end
  end

  class MissingParam < Error
    include Lucky::RenderableError

    getter :param_name

    def initialize(@param_name : String)
    end

    def message : String
      "Missing parameter: '#{param_name}''"
    end

    def renderable_status
      400
    end

    def renderable_message
      messagee
    end
  end

  class MissingNestedParam < Error
    include Lucky::RenderableError

    getter :nested_key

    def initialize(@nested_key : String | Symbol)
    end

    def message : String
      "Missing param key: #{nested_key}"
    end

    def renderable_status
      400
    end

    def renderable_message
      "Missing param key: '#{nested_key}'"
    end
  end

  class MissingFile < Error
    getter :path

    def initialize(@path : String)
    end

    def message : String
      "Cannot read file #{path}"
    end
  end

  class InvalidFlashJSON < Error
    getter bad_json

    def initialize(@bad_json : String?)
    end

    def message : String?
      <<-MESSAGE
      The flash messages (stored as JSON) failed to parse in a JSON parser.
      Here's what it tries to parse:

      #{bad_json}
      MESSAGE
    end
  end
end
