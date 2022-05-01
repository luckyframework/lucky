module Lucky
  module SecureHeaders
    # This module sets the HTTP header [Content-Security-Policy](https://wiki.owasp.org/index.php/OWASP_Secure_Headers_Project#csp).
    # It's job is to prevent a wide range of attacks like Cross-Site Scripting.
    #
    # Include this module in the actions you want to add this to.
    # A required method `csp_guard_value` must be defined
    # ```
    # class BrowserAction < Lucky::Action
    #   include Lucky::SecureHeaders::SetCSPGuard
    #
    #   def csp_guard_value : String
    #     "script-src 'self'"
    #   end
    # end
    # ```
    module SetCSPGuard
      macro included
        before set_csp_guard_header
      end

      abstract def csp_guard_value : String

      private def set_csp_guard_header
        context.response.headers["Content-Security-Policy"] = csp_guard_value
        continue
      end
    end
  end
end
