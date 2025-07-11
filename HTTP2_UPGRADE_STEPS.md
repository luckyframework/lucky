# HTTP/2 Upgrade Steps for Lucky Applications

This guide outlines the steps needed to enable HTTP/2 support in an existing Lucky application using the `nomadlabsinc/ht2` shard.

## Prerequisites

- Crystal >= 1.10.0
- TLS certificate and private key files
- Lucky framework >= 1.4.0

## Step 1: Install Dependencies

Add the ht2 dependency to your `shard.yml`:

```yaml
dependencies:
  ht2:
    github: nomadlabsinc/ht2
    branch: main
```

Run `shards install` to install the new dependency.

## Step 2: Generate TLS Certificates

HTTP/2 requires TLS certificates. For development, you can generate self-signed certificates:

```bash
# Generate private key
openssl genrsa -out server.key 2048

# Generate self-signed certificate
openssl req -new -x509 -key server.key -out server.crt -days 365 -subj "/CN=localhost"
```

For production, use certificates from a trusted Certificate Authority.

## Step 3: Configure HTTP/2 Settings

In your `config/server.cr` file, add HTTP/2 configuration:

```crystal
Lucky::Server.configure do |settings|
  # Existing settings...
  
  # HTTP/2 Configuration
  settings.http2_enabled = true
  settings.http2_cert_file = "./server.crt"
  settings.http2_key_file = "./server.key"
  settings.http2_max_concurrent_streams = 100  # Optional
  settings.http2_max_frame_size = 16384        # Optional
end
```

## Step 4: Update Your App Server

Modify your app server class to inherit from `Lucky::HTTP2AppServer` instead of `Lucky::BaseAppServer`:

### Before (HTTP/1.1):
```crystal
class AppServer < Lucky::BaseAppServer
  def middleware : Array(HTTP::Handler)
    [
      # Your middleware handlers
    ] of HTTP::Handler
  end

  def listen
    @server.bind_tcp(host, port)
    @server.listen
  end
end
```

### After (HTTP/2):
```crystal
class AppServer < Lucky::HTTP2AppServer
  def middleware : Array(HTTP::Handler)
    [
      # Your middleware handlers (unchanged)
    ] of HTTP::Handler
  end
end
```

Note: The `listen` method is no longer needed as it's handled by the parent class.

## Step 5: Compile with HTTP/2 Flag

Compile your application with the `http2` flag to enable HTTP/2 support:

```bash
# Development
crystal build src/app.cr -Dhttp2

# Production
crystal build src/app.cr --release -Dhttp2

# Using Lucky CLI (if available)
lucky build -Dhttp2
```

## Step 6: Update Your Startup Script

If you have startup scripts or deployment configurations, ensure they include the HTTP/2 compilation flag:

```bash
#!/bin/bash
crystal build src/app.cr --release -Dhttp2
./app
```

## Step 7: Test HTTP/2 Connection

Test your HTTP/2 server using curl:

```bash
# Test HTTP/2 connection (skip certificate verification for self-signed certs)
curl -k --http2 https://localhost:3000

# Check HTTP/2 protocol usage
curl -k --http2 -I https://localhost:3000
```

## Configuration Reference

### HTTP/2 Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `http2_enabled` | Bool | false | Enable/disable HTTP/2 support |
| `http2_cert_file` | String | "" | Path to TLS certificate file |
| `http2_key_file` | String | "" | Path to TLS private key file |
| `http2_max_concurrent_streams` | Int32 | 100 | Maximum concurrent HTTP/2 streams |
| `http2_max_frame_size` | Int32 | 16384 | Maximum HTTP/2 frame size |

### Environment Variables

You can also configure HTTP/2 settings using environment variables:

```bash
export HTTP2_ENABLED=true
export HTTP2_CERT_FILE=./ssl/server.crt
export HTTP2_KEY_FILE=./ssl/server.key
```

## Important Notes

1. **TLS is Required**: HTTP/2 requires TLS certificates. The server will not start without valid certificate files when HTTP/2 is enabled.

2. **Compilation Flag**: Always use the `-Dhttp2` flag when building your application for HTTP/2 support.

3. **Middleware Compatibility**: Existing Lucky middleware should work unchanged with HTTP/2.

4. **Development vs Production**: Use self-signed certificates for development and trusted CA certificates for production.

5. **Browser Support**: Modern browsers automatically use HTTP/2 when available over HTTPS connections.

## Troubleshooting

### Common Issues

1. **Certificate Errors**: Ensure certificate and key files exist and are readable by the application.

2. **Compilation Errors**: Make sure to include the `-Dhttp2` flag during compilation.

3. **Connection Refused**: Verify the port is not already in use and firewall settings allow connections.

4. **HTTP/1.1 Fallback**: If HTTP/2 negotiation fails, connections will fallback to HTTP/1.1.

### Debug Commands

```bash
# Check if HTTP/2 is negotiated
curl -k --http2 -v https://localhost:3000

# Test with specific HTTP version
curl -k --http2-prior-knowledge https://localhost:3000
```

## Migration Checklist

- [ ] Add ht2 dependency to shard.yml
- [ ] Generate or obtain TLS certificates
- [ ] Configure HTTP/2 settings in config/server.cr
- [ ] Update app server to inherit from Lucky::HTTP2AppServer
- [ ] Add -Dhttp2 compilation flag to build process
- [ ] Test HTTP/2 connectivity
- [ ] Update deployment scripts
- [ ] Verify middleware compatibility

## Performance Considerations

HTTP/2 provides several performance benefits:

- **Multiplexing**: Multiple requests over a single connection
- **Server Push**: Proactively send resources to clients
- **Header Compression**: Reduced overhead with HPACK
- **Binary Protocol**: More efficient than HTTP/1.1 text protocol

Monitor your application performance after migration to ensure optimal configuration.