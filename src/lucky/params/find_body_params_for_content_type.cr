require "./*"

# Finds the right type of body params based on the request's content type.
#
# For example, the content type 'application/json' will return an object for
# finding params in a JSON body.
struct Lucky::Params::FindBodyParamsForContentType
  @request : HTTP::Request
  @route_params : Hash(String, String)

  def initialize(@request, @route_params = {} of String => String)
  end

  def call : Lucky::Params::BodyParams
    paramable =
      if json?
        Lucky::Params::JsonParams
      elsif multipart?
        Lucky::Params::MultipartFormParams
      else
        Lucky::Params::UrlEncodedFormParams
      end

    paramable.new(@request, @route_params)
  end

  private def json? : Bool
    content_type.try(&.match(/^application\/json/))
  end

  private def multipart? : Bool
    content_type.try(&.match(/^multipart\/form-data/))
  end

  private def content_type : String?
    request.headers["Content-Type"]?
  end
end
