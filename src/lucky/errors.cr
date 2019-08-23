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
    getter request

    def initialize(@request : HTTP::Request)
      super "Failed to parse the request parameters."
    end
  end

  class UnknownAcceptHeaderError < Error
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
  end

  class NotAcceptableError < Error
    getter request

    def initialize(action_name : String, format : Symbol, accepted_formats : Array(Symbol))
      super <<-TEXT
      The request wants :#{format}, but #{action_name} does not accept it.

      Accepted formats: #{accepted_formats.map(&.to_s).join(", ")}

      Try this...

        ▸ Add :#{format} to 'accepted_formats' in #{action_name}.
        ▸ Make your request is using one of the accepted formats.


      TEXT
    end
  end
end
