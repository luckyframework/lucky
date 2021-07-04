# Include this in your actions to enforce underscores are used in your paths
#
# This is purely to help maintain consistency in your app and can be removed if
# desired.
module Lucky::EnforceUnderscoredRoute
  macro enforce_route_style(path, action)
    {% if path.includes?("-") %}
      {% raise <<-ERROR
      #{path} defined in '#{action}' should use an underscore.

      In '#{action}'

        ▸ Change #{path}
        ▸ To #{path.gsub(/-/, "_")}

      Or, skip the style check for this action

          class #{action}
        +  include Lucky::SkipRouteStyleCheck
          end

      Or, skip checking all actions by removing 'Lucky::EnforceUnderscoredRoute'

          # Remove from both BrowserAction and ApiAction
          class BrowserAction/ApiAction
        -  include Lucky::EnforceUnderscoredRoute
          end


      ERROR
      %}
    {% end %}
  end
end
