# Include this in your actions to enforce underscores are used in your paths
#
# This is purely to help maintain consistency in your app and can be removed if
# desired.
module Lucky::EnforceUnderscoredRoute
  macro enforce_route_style(path, action)
    {% if path.includes?("-") %}
      {% raise <<-ERROR
      #{path} defined in #{action} includes a dash, but should use an underscore.

      Try this...

        ▸ Change #{path} to #{path.gsub(/-/, "_")}

      Or, skip checking this action...

          class #{action}
            include Lucky::SkipPathStyleCheck
          end

      Or, skip checking all actions by removing `Lucky::EnforceUnderscoredRoute` from `BrowserAction` and `ApiAction`

      ERROR
      %}
    {% end %}
  end
end
