module Lucky
  # = Lucky Errors
  #
  # Generic Lucky Record exception class.
  class Error < Exception
  end

  # Raised when a route could not be found
  class RouteNotFoundError < Error
    def initialize(method : String, path : String)
      super "Could not find route matching #{method} #{path}"
    end
  end
end
