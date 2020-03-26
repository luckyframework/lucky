# :nodoc:
class Lucky::RequestBodyReader
  getter request : HTTP::Request

  def initialize(@request)
  end

  def body : String
    (request.body || IO::Memory.new).gets_to_end.tap do |request_body|
      request.body = IO::Memory.new(request_body)
    end
  end
end
