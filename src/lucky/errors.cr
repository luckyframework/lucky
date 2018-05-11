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
end
