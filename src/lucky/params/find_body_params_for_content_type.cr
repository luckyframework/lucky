require "./*"

# This class returns a param objects based on the content type
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
end
