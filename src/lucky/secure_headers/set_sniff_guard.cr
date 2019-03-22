module Lucky
  module SecureHeaders
    # This module sets the HTTP header [X-Content-Type-Options](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options).
    # It's job is responsible for disabling mime type sniffing.
    # For more information, read up on [MIME type security](https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/compatibility/gg622941(v=vs.85)).
    #
    # Include this module in the actions you want to add this to.
    # ```
    # class BrowserAction < Lucky::Action
    #   include Lucky::SecureHeaders::SetSniffGuard
    # end
    # ```
    module SetSniffGuard
      macro included
        before set_sniff_guard_header
      end

      private def set_sniff_guard_header
        context.response.headers["X-Content-Type-Options"] = "nosniff"
        continue
      end
    end
  end
end
