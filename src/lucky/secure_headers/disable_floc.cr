module Lucky
  module SecureHeaders
    # This module disables Google FLoC by setting the
    # [Permissions-Policy](https://github.com/WICG/floc) HTTP header to `interest-cohort=()`.
    #
    # This header is a part of Google's Federated Learning of Cohorts (FLoC) which is used
    # to track browsing history instead of using 3rd-party cookies.
    #
    # Include this module in the actions you want to disable this feature.

    # ```
    # class BrowserAction < Lucky::Action
    #   include Lucky::SecureHeaders::DisableFLoC
    # end
    # ```
    module DisableFLoC
      macro included
        before set_floc_guard_header
      end

      private def set_floc_guard_header
        unless context.response.headers["Permissions-Policy"]?
          context.response.headers["Permissions-Policy"] = floc_guard_value
        end
        continue
      end

      private def floc_guard_value
        "interest-cohort=()"
      end
    end
  end
end
