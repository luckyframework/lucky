module Lucky
  module SecureHeaders
    # This module sets the HTTP header [X-Frame-Options](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options).
    # It's job is responsible for deciding which site can call your site from within a frame.
    # For more information, read up on [Clickjacking](https://en.wikipedia.org/wiki/Clickjacking).
    #
    # Include this module in the actions you want to add this to.
    # A required method `frame_guard_options` must be defined`
    # ```
    # class BrowserAction < Lucky::Action
    #   include Lucky::SecureHeaders::SetFrameGuard
    #
    #   def frame_guard_options
    #     {allow_from: "deny"}
    #   end
    # end
    # ```
    #
    # ### Options
    # The `frame_guard_options` method must be defined and return `NamedTuple(allow_from: String)`
    # The `allow_from` key can have one of 3 String values:
    # - `"same"` or `"sameorigin"`
    # - `"nowhere" or `"deny"`
    # - a valid URL e.g. `"https://mysite.com"`
    module SetFrameGuard
      macro included
        before set_frame_guard_header
      end

      abstract def frame_guard_options : NamedTuple(allow_from: String)

      private def set_frame_guard_header
        context.response.headers["X-Frame-Options"] = frame_guard_value(frame_guard_options)
        continue
      end

      private def frame_guard_value(options)
        case options[:allow_from].downcase
        when "same", "sameorigin"
          "sameorigin"
        when "nowhere", "deny"
          "deny"
        else
          "allow-from #{options[:allow_from]}"
        end
      end
    end
  end
end
