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
      include Lucky::RenderableError
      getter :param_name, :param_value, :param_type

      def initialize(@param_name : String, @param_value : String, @param_type : String)
      end

      def message : String?
        "Required param \"#{param_name}\" with value \"#{param_value}\" couldn't be parsed to a \"#{param_type}\""
      end

      def http_status : Int32
        HTTP::Status::UNPROCESSABLE_ENTITY.value
      end

      def renderable_message
        "Required param \"#{param_name}\" with value \"#{param_value}\" couldn't be parsed to a \"#{param_type}\""
      end
    end

    class MissingParam < Base
      getter :param_name

      def initialize(@param_name : String)
      end

      def message : String
        "Missing parameter: #{param_name}"
      end
    end

    class MissingNestedParam < Base
      getter :nested_key

      def initialize(@nested_key : String | Symbol)
      end

      def message : String
        "Missing nested params: #{nested_key}"
      end
    end

    class MissingFile < Base
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
end
