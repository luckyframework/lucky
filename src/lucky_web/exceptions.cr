module LuckyWeb
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
  end
end
