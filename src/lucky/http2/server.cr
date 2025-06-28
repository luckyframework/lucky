class Lucky::HTTP2::Server
  private getter server

  def initialize(middleware : Array(HTTP::Handler))
    adapter = Lucky::HTTP2::HandlerAdapter.new(middleware)
    handler = ->(context : HT2::Context) {
      adapter.call(context.request, context.response)
    }
    @server = HT2::Server.new(
      host: Lucky::Server.settings.host,
      port: Lucky::Server.settings.port,
      handler: handler,
      tls_context: build_tls_context
    )
  end

  def listen
    server.listen
  end

  def close
    server.close
  end

  private def build_tls_context
    # This is a placeholder. In a real implementation, this would
    # need to be configured with the application's certificate and key.
    # For now, we'll generate a self-signed certificate for development.
    key = OpenSSL::PKey::RSA.new(2048)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.parse("/CN=localhost")
    cert.issuer = cert.subject
    cert.public_key = key.public_key
    cert.not_before = Time.utc - 1.day
    cert.not_after = Time.utc + 1.year
    cert.sign(key, OpenSSL::Digest::SHA256.new)

    tls = OpenSSL::SSL::Context::Server.new
    tls.private_key = key
    tls.certificate_chain = [cert]
    tls
  end
end
