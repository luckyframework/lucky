# HTTP2 App Server for Lucky applications
#
# This class provides HTTP/2 support using the ht2 shard.
# It requires TLS certificates and is enabled via the http2_enabled setting.
{% if flag?(:http2) %}
  require "ht2"

  abstract class Lucky::HTTP2AppServer
    private getter server : HT2::Server?

    abstract def middleware : Array(HTTP::Handler)

    def initialize
      if Lucky::Server.settings.http2_enabled
        cert_file = Lucky::Server.settings.http2_cert_file
        key_file = Lucky::Server.settings.http2_key_file
        enable_h2c = Lucky::Server.settings.http2_enable_h2c

        # Determine TLS context
        tls_context = nil
        if cert_file && key_file
          tls_context = HT2::Server.create_tls_context(cert_file, key_file)
        elsif !enable_h2c
          raise "HTTP/2 enabled but neither TLS certificates nor h2c mode configured. Either set certificate files or enable h2c."
        end

        handler = create_http2_handler
        h2c_timeout = Lucky::Server.settings.http2_h2c_upgrade_timeout.seconds

        @server = HT2::Server.new(
          host: host,
          port: port,
          handler: handler,
          enable_h2c: enable_h2c,
          h2c_upgrade_timeout: h2c_timeout,
          max_concurrent_streams: Lucky::Server.settings.http2_max_concurrent_streams.to_u32,
          max_frame_size: Lucky::Server.settings.http2_max_frame_size.to_u32,
          tls_context: tls_context
        )
      end
    end

    def listen
      if server = @server
        server.listen
      else
        raise "HTTP/2 server not initialized. Ensure http2_enabled is true and certificates are configured."
      end
    end

    def close : Nil
      @server.try(&.close)
    end

    private def host : String
      Lucky::Server.settings.host
    end

    private def port : Int32
      Lucky::Server.settings.port
    end

    private def create_http2_handler
      middleware_chain = middleware

      ->(request : HT2::Request, response : HT2::Response) do
        context = create_http_context(request, response)

        begin
          middleware_chain.each do |handler|
            handler.call(context)
          end
        rescue ex
          response.status = 500
          response.headers["content-type"] = "text/plain"
          response.write("Internal Server Error")
          response.close
        end
      end
    end

    private def create_http_context(request : HT2::Request, response : HT2::Response) : HTTP::Server::Context
      http_request = HTTP::Request.new(
        method: request.method,
        resource: request.path + (request.query_string.empty? ? "" : "?" + request.query_string),
        headers: request.headers,
        body: request.body
      )

      http_response = Lucky::HTTP2ResponseAdapter.new(response)
      HTTP::Server::Context.new(http_request, http_response)
    end
  end
{% end %}
