require "http/client"

class Lucky::Request
  getter! url
  getter! headers
  getter! query_params
  getter! response

  @url : String? = nil
  @headers : HTTP::Headers? = nil
  @query_params : String? = nil
  @response : HTTP::Client::Response? = nil

  def get(path : String, as user = nil, headers : HTTP::Headers? = nil)
    request("GET", path, nil, headers, as: user)
  end

  def put(path : String, body : Hash(String, String), as user = nil, headers : HTTP::Headers? = nil)
    request("PUT", path, body, headers, as: user)
  end

  def post(path : String, body : Hash(String, String), as user = nil, headers : HTTP::Headers? = nil)
    request("POST", path, body, headers, as: user)
  end

  def delete(path : String, as user = nil, headers : HTTP::Headers? = nil)
    request("DELETE", path, nil, headers, as: user)
  end

  def response
    @response.not_nil!
  end

  def response_body
    if response.success?
      response.body
    else
      raise Exception.new(response.body)
    end
  end

  def response_json
    JSON.parse(response_body)
  end

  private def request(method : String, path : String, body : Hash(String, String)? = nil, headers : HTTP::Headers? = nil, as user = nil)
    if user
      headers ||= HTTP::Headers.new
      headers.add "Authorization", user.generate_token
    end

    @url = Lucky::RouteHelper.settings.base_uri + path
    @headers = headers
    @query_params = body ? hash_to_params(body) : nil

    @response = HTTP::Client.exec(method, url: url, body: @query_params, headers: headers)
  end

  private def hash_to_params(body : Hash(String, String))
    body_strings = [] of String
    body.each do |key, value|
      body_strings << "#{URI.escape(key)}=#{URI.escape(value)}"
    end
    body_strings.join("&")
  end

  private def hash_to_headers(hash : Hash(String, String))
    headers = HTTP::Headers.new
    hash.keys.map { |key| headers.add key, hash[key] }
    headers
  end
end
