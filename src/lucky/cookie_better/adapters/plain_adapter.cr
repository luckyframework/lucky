class Lucky::Adapters::PlainAdapter
  def write(
    key : String,
    cookies : Lucky::CookieJar,
    to response : HTTP::Server::Response
  ) : Void
    response.cookies[key] = cookies.to_json
    add_cookies_to_response(response)
  end

  private def add_cookies_to_response(response : HTTP::Server::Response)
    response.cookies.add_response_headers(response.headers)
  end

  def read(key : String, from request : HTTP::Request) : Lucky::CookieJar
    Lucky::CookieJar.new.tap do |cookie_jar|
      cookie = request.cookies[key]? || HTTP::Cookie.new(key, "{}")
      JSON.parse(cookie.value).as_h.each do |key, value|
        cookie_jar.set key, value.to_s
      end
    end
  end
end
