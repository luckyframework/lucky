module Lucky::Subdomain
  # Taken from https://github.com/rails/rails/blob/afc6abb674b51717dac39ea4d9e2252d7e40d060/actionpack/lib/action_dispatch/http/url.rb#L8
  IP_HOST_REGEXP = /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/

  Habitat.create do
    # tld_length is the number of Top Level Domain segments separated by periods
    # the default is 1 because most domains end in ".com" or ".org"
    # The tld_length should be changed to 2 when you have a ".co.uk" domain for example
    # It can also be changed to 0 for local development so that you can use `tenant.localhost:3000`
    setting tld_length : Int32 = 1
  end

  alias Matcher = String | Regex | Bool | Array(String | Regex) | Array(String) | Array(Regex)

  # Sets up a subdomain requirement for an action
  #
  # ```
  # require_subdomain                                    # subdomain required but can be anything
  # require_subdomain "admin"                            # subdomain required and must equal "admin"
  # require_subdomain /(dev|qa|prod)/                    # subdomain required and must match regex
  # require_subdomain ["tenant1", "tenant2", /tenant\d/] # subdomain required and must match one of the items in the array
  # ```
  #
  # The subdomain can then be accessed from within the route block by calling `subdomain`.
  #
  # If you don't want to require a subdomain but still want to check if one is passed
  # you can still call `subdomain?` without using `require_subdomain`.
  # Just know that `subdomain?` is nilable.
  macro require_subdomain(matcher = true)
    before _match_subdomain

    private def subdomain : String
      subdomain?.not_nil!
    end

    private def _match_subdomain
      _match_subdomain({{ matcher }})
    end
  end

  private def subdomain : String
    {% raise "No subdomain available without calling `require_subdomain` first." %}
  end

  private def subdomain? : String?
    host = request.hostname
    return if host.nil? || IP_HOST_REGEXP.matches?(host)

    parts = host.split('.')
    parts.pop(Lucky::Subdomain.settings.tld_length + 1)

    parts.empty? ? nil : parts.join(".")
  end

  private def _match_subdomain(matcher : Matcher)
    expected = [matcher].flatten.compact
    return continue if expected.empty?

    actual = subdomain?
    result = expected.any? do |expected_subdomain|
      case expected_subdomain
      when true
        actual.present?
      when Symbol
        actual.to_s == expected_subdomain.to_s
      else
        expected_subdomain === actual
      end
    end

    if result
      continue
    else
      raise InvalidSubdomainError.new(host: request.hostname, expected: matcher)
    end
  end
end
