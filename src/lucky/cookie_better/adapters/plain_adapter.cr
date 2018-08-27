class Lucky::Adapters::PlainAdapter
  def write(
    cookies : Lucky::CookieJar,
    to response : HTTP::Server::Response
  ) : Void
    cookies.to_h.each do |key, value|
      response.cookies << HTTP::Cookie.new(name: key, value: value)
    end
    add_cookies_to(response)
  end

  private def add_cookies_to(response : HTTP::Server::Response)
    response.cookies.add_response_headers(response.headers)
  end

  def read(from request : HTTP::Request) : Lucky::CookieJar
    Lucky::CookieJar.new.tap do |cookie_jar|
      request.cookies.each do |cookie|
        cookie_jar.set(cookie.name, cookie.value)
      end
    end
  end
end
