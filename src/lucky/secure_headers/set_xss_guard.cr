module Lucky
  module SecureHeaders
    # This module sets the HTTP header
    # [X-XSS-Protection](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection).
    # It's job is responsible for telling the browser to not render a page if
    # it detects cross-site scripting. Lucky disables this header for Internet
    # Explorer version < 9 for you as per recommendations. Read more on
    # [Microsoft](https://blogs.msdn.microsoft.com/ieinternals/2011/01/31/controlling-the-xss-filter/).
    #
    # Include this module in the actions you want to add this to.

    # ```
    # class BrowserAction < Lucky::Action
    #   include Lucky::SecureHeaders::SetXSSGuard
    # end
    # ```
    module SetXSSGuard
      macro included
        before set_xss_guard_header
      end

      private def set_xss_guard_header
        context.response.headers["X-XSS-Protection"] = xss_guard_value
        continue
      end

      private def xss_guard_value
        useragent = context.request.headers.fetch("User-Agent", "").downcase
        value = "1; mode=block"
        useragent.match(/msie\s+(\d+)/).try { |match|
          value = "0" if match[1].to_i < 9
        }
        value
      end
    end
  end
end
