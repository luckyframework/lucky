# :nodoc:
class Lucky::RequestBodyReader
  getter request : HTTP::Request

  def initialize(@request : HTTP::Request)
  end

  # Returns the body of the `request` and
  # reassigns the value back to the request body
  # to allow for re-reading
  def body : String
    contents = request.body.try(&.gets_to_end) || ""
    request.body = IO::Memory.new(contents)
    contents
  end
end
