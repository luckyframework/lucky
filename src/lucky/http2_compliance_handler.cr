# HTTP/2 Compliance Handler
#
# This handler ensures all response headers comply with HTTP/2 naming conventions
# by normalizing them to lowercase with dashes. It runs after all other processing
# to ensure the final headers sent to the client are HTTP/2 compliant.
#
# Include this handler in your middleware stack to enable HTTP/2 header compliance:
#
# ```
# middleware_stack = [
#   # ... other middleware
#   Lucky::HTTP2ComplianceHandler.new,
# ]
# ```
class Lucky::HTTP2ComplianceHandler
  include HTTP::Handler
  
  def call(context : HTTP::Server::Context)
    call_next(context)
    # Normalize headers after all processing is complete
    normalize_response_headers(context.response.headers)
  end
  
  private def normalize_response_headers(headers : HTTP::Headers) : Nil
    # Create a list of headers to normalize
    headers_to_normalize = [] of {String, String, Array(String)}
    
    headers.each do |name, values|
      lowercase_name = name.downcase.gsub("_", "-")
      if name != lowercase_name
        headers_to_normalize << {name, lowercase_name, values}
      end
    end
    
    # Apply normalizations
    headers_to_normalize.each do |original_name, lowercase_name, values|
      headers.delete(original_name)
      values.each do |value|
        headers.add(lowercase_name, value)
      end
    end
  end
end