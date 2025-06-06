# HTTP/2 Header Management for Lucky Framework
#
# This module provides utilities to ensure HTTP/2 compliance by managing headers
# with lowercase names and dashes instead of underscores, as required by RFC 7540.
#
# The module works around Crystal's header normalization behavior while maintaining
# compatibility with existing code that expects Title-Case headers.
module Lucky::HTTP2Headers
  # Sets a header with HTTP/2 compliant naming (lowercase with dashes)
  # and removes any existing variants to prevent duplication
  def self.set_compliant(headers : HTTP::Headers, name : String, value : String) : Nil
    lowercase_name = name.downcase.gsub("_", "-")
    
    # Remove any existing variants (titlecase, uppercase, etc.)
    headers.delete(name)
    headers.delete(name.titleize)
    headers.delete(name.upcase)
    headers.delete(lowercase_name)
    
    # Set with lowercase name
    headers[lowercase_name] = value
  end
  
  # Gets a header value using HTTP/2 compliant name lookup
  def self.get_compliant(headers : HTTP::Headers, name : String) : String?
    lowercase_name = name.downcase.gsub("_", "-")
    headers[lowercase_name]?
  end
  
  # Normalizes all headers in a collection to be HTTP/2 compliant
  # This creates a new header collection with all lowercase names
  def self.normalize_all(headers : HTTP::Headers) : HTTP::Headers
    normalized = HTTP::Headers.new
    
    headers.each do |name, value|
      lowercase_name = name.downcase.gsub("_", "-")
      normalized[lowercase_name] = value
    end
    
    normalized
  end
  
  # Checks if headers contain HTTP/2 compliant names only
  def self.compliant?(headers : HTTP::Headers) : Bool
    headers.each do |name, value|
      return false unless name == name.downcase
      return false if name.includes?("_")
      return false unless name.match(/^[a-z0-9\-]+$/)
    end
    true
  end
  
  # List of headers that should be normalized for HTTP/2 compliance
  STANDARD_HEADERS = {
    "Content-Type" => "content-type",
    "Content-Length" => "content-length", 
    "Content-Encoding" => "content-encoding",
    "Content-Disposition" => "content-disposition",
    "Content-Transfer-Encoding" => "content-transfer-encoding",
    "Content-Security-Policy" => "content-security-policy",
    "Accept-Encoding" => "accept-encoding",
    "Accept-Ranges" => "accept-ranges",
    "User-Agent" => "user-agent",
    "X-Frame-Options" => "x-frame-options",
    "X-XSS-Protection" => "x-xss-protection",
    "X-Content-Type-Options" => "x-content-type-options",
    "X-Forwarded-For" => "x-forwarded-for",
    "X-Forwarded-Proto" => "x-forwarded-proto",
    "X-Requested-With" => "x-requested-with",
    "X-CSRF-TOKEN" => "x-csrf-token",
    "X-Xhr-Redirect" => "x-xhr-redirect",
    "Permissions-Policy" => "permissions-policy",
    "Strict-Transport-Security" => "strict-transport-security",
    "Last-Modified" => "last-modified",
    "If-Modified-Since" => "if-modified-since",
    "Turbolinks-Referrer" => "turbolinks-referrer",
    "Turbolinks-Location" => "turbolinks-location",
    "Retry-After" => "retry-after",
    "Location" => "location",
    "Referer" => "referer",
    "Host" => "host",
    "Date" => "date",
    "Etag" => "etag"
  }
end