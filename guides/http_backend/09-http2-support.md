# HTTP/2 Support

Lucky includes optional HTTP/2 support, allowing you to leverage modern web protocols while maintaining full backward compatibility with your existing HTTP/1.1 applications.

## Enabling HTTP/2

Add this to your `config/server.cr`:

```crystal
Lucky::Server.configure do |settings|
  settings.http2_enabled = true
end
```

That's it! Your app now supports HTTP/2 connections.

## Creating HTTP/2 Actions

HTTP/2 actions inherit from `Lucky::HTTP2::Action`:

```crystal
class Api::Users::Show < Lucky::HTTP2::Action
  def call
    # Access route params
    user_id = route_params["id"]
    
    # Write response
    context.response.headers["content-type"] = "application/json"
    context.response.write({user_id: user_id}.to_json.to_slice)
  end
end
```

## Defining HTTP/2 Routes

Use the `http2` macro in your routes file:

```crystal
# Regular HTTP/1.1 route
get "/users/:id", Users::Show

# HTTP/2-specific route
http2 :get, "/api/v2/users/:id", Api::Users::Show
```

You can even have both HTTP/1.1 and HTTP/2 handlers for the same path:

```crystal
get "/dashboard", Dashboard::Show           # HTTP/1.1
http2 :get, "/dashboard", Dashboard::HTTP2Show  # HTTP/2
```

## How It Works

When HTTP/2 is enabled:
1. Lucky starts an HTTP/2 server on the same port
2. HTTP/2 requests check for matching `http2` routes first
3. If no HTTP/2 route matches, the request falls back to your HTTP/1.1 routes
4. All your existing middleware and handlers continue to work

## Why Use HTTP/2?

- **Multiplexing**: Multiple requests over a single connection
- **Server Push**: Proactively send resources to clients
- **Header Compression**: Reduced overhead with HPACK
- **Binary Protocol**: More efficient parsing

## Gradual Migration

The beauty of Lucky's HTTP/2 support is that it's completely opt-in:

1. Enable HTTP/2 in your config
2. Start adding `http2` routes for endpoints that benefit most
3. Your existing routes keep working exactly as before
4. Migrate at your own pace

No need to rewrite your entire app!

## Running Without TLS (Behind a Load Balancer)

By default, Lucky's HTTP/2 server uses TLS with a self-signed certificate for development. However, if you're terminating TLS at a load balancer (like AWS ALB, Cloudflare, or nginx) and want HTTP/2 throughout your stack, you can disable TLS:

```crystal
# config/server.cr
Lucky::Server.configure do |settings|
  settings.http2_enabled = true
  settings.http2_tls_enabled = false  # Disable TLS for HTTP/2
end
```

This is useful when:
- Your load balancer handles TLS termination
- You want HTTP/2 benefits within your internal network
- You're running in a trusted environment (like Kubernetes with service mesh)

### Example Load Balancer Configurations

**nginx:**
```nginx
upstream app {
    server localhost:3000;
    keepalive 256;
}

server {
    listen 443 ssl http2;
    
    # TLS config here...
    
    location / {
        proxy_pass http://app;
        proxy_http_version 2.0;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**AWS ALB:**
- Set target group protocol to HTTP/2
- ALB handles TLS termination
- Your Lucky app receives plain HTTP/2

**Note:** When running without TLS, ensure your network is secure. Never disable TLS in production unless you're certain TLS is handled upstream.