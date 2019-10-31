module Lucky
  module SecureHeaders
    # This module sets the HTTP header [X-Frame-Options](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options).
    # It's job is responsible for deciding which site can call your site from within a frame.
    # For more information, read up on [Clickjacking](https://en.wikipedia.org/wiki/Clickjacking).
    #
    # Include this module in the actions you want to add this to.
    # A required method `frame_guard_value` must be defined`
    # ```
    # class BrowserAction < Lucky::Action
    #   include Lucky::SecureHeaders::SetFrameGuard
    #
    #   def frame_guard_value : String
    #     "deny"
    #   end
    # end
    # ```
    #
    # ### Options
    # The `frame_guard_value` method must be defined and return a `String`
    # It can have one of 3 String values:
    # - `"sameorigin"`
    # - `"deny"`
    # - a valid URL e.g. `"https://mysite.com"`
    module SetFrameGuard
      macro included
        before set_frame_guard_header
      end

      abstract def frame_guard_value : String

      private def set_frame_guard_header
        context.response.headers["X-Frame-Options"] = check_frame_guard_value!(frame_guard_value)
        continue
      end

      private def check_frame_guard_value!(value : String)
        v = value.downcase
        case v
        when "sameorigin", "deny"
          v
        when /^https?:\/\/\w+./
          "allow-from #{v}"
        else
          raise <<-MESSAGE

          You set frame_guard_value to #{value}, but it must be one of these options:

            - "sameorigin"
            - "deny"
            - A valid URL
          MESSAGE
        end
      end
    end
  end
end
