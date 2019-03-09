require "http/client"

class Lucky::BaseHTTPClient
  @client : HTTP::Client

  def initialize(host = Lucky::Server.settings.host, port = Lucky::Server.settings.port)
    @client = HTTP::Client.new(host, port: port)
  end

  def get(path : String, headers : HTTP::Headers? = nil, params : HTTP::Params? = nil)
    if params
      path = path + "?#{params}"
    end
    @client.get(path, headers: headers)
  end

  {% for method in [:put, :patch, :post] %}

    def {{method.id}}(path : String, body : Hash(String, String), headers : HTTP::Headers? = nil)
      @client.{{method.id}}(path, headers: headers, form: body)
    end

  {% end %}

  def delete(path : String, headers : HTTP::Headers? = nil)
    @client.delete(path, headers: headers)
  end
end
