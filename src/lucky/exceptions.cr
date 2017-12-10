module Lucky
  module Exceptions
    class Base < Exception
    end

    # Raised when storing more than 4K of session data.
    class CookieOverflow < Base
    end

    class InvalidSignature < Base
    end

    class InvalidMessage < Base
    end

    class InvalidParam < Base
      def initialize(@param_name : String, @param_value : String, @param_type : String)
      end

      def message : String?
        "Non-optional param \"#{@param_name}\" with value \"#{@param_value}\" couldn't be parsed to a \"#{@param_type}\""
      end
    end

    class MissingParam < Base
      def initialize(@param_name : String)
      end

      def message : String?
        "Missing parameter: #{@param_name}"
      end
    end
  end
end
