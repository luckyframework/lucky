class Lucky::RouteHelper
  Habitat.create do
    setting base_uri : String
  end

  getter method : Symbol
  getter path : String
  getter subdomain : String?

  def initialize(@method : Symbol, @path : String, @subdomain : String? = nil)
  end

  def url : String
    if subdomain
      build_subdomain_url
    else
      settings.base_uri + path
    end
  end

  private def build_subdomain_url : String
    uri = URI.parse(settings.base_uri)
    host = uri.host || raise "URI host cannot be nil"
    subdomain_value = subdomain || raise "Subdomain cannot be nil in build_subdomain_url"

    # Replace the existing subdomain or add one
    host_parts = host.split('.')
    if subdomain_exists_in_host?(host_parts)
      host_parts[0] = subdomain_value
    else
      host_parts.unshift(subdomain_value)
    end

    new_host = host_parts.join('.')
    uri.host = new_host
    uri.to_s + path
  end

  private def subdomain_exists_in_host?(host_parts : Array(String)) : Bool
    # If we have more than 2 parts (subdomain.domain.tld), assume subdomain exists
    # This is a simple heuristic and could be made more sophisticated
    host_parts.size > 2
  end

  def_equals @method, @path, @subdomain
end
