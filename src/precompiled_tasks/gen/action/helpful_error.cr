require "colorize"

puts <<-ERROR
    Missing 'browser' or 'api' after 'gen.action'

    For actions used in a browser (HTML, redirects)...

        #{"lucky gen.action.browser".colorize.green.bold}

    For an API endpoint (JSON, XML, GraphQL)...

        #{"lucky gen.action.api".colorize.green.bold}


    ERROR
