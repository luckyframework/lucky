class Lucky::Adapters::PlainAdapter
  def write(
    key : String,
    cookies : Lucky::CookieJar,
    to response : HTTP::Server::Response
  ) : Void
    response.cookies[key] = cookies.to_json
    response.cookies.add_response_headers(response.headers)
  end

  def read(request : HTTP::Server::Request) : Lucky::CookieJar
  end
end
