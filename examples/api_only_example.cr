# Example: API-only Lucky application
# Compile with: crystal build examples/api_only_example.cr -D lucky_no_html
#
# This demonstrates how to create a Lucky app without HTML functionality
# for pure API applications, resulting in smaller binary size.

require "../src/lucky"

class Api::V1::Status < Lucky::Action
  get "/api/v1/status" do
    json({
      status: "ok",
      version: "1.0.0",
      timestamp: Time.utc.to_unix
    })
  end
end

class Api::V1::Users::Index < Lucky::Action
  get "/api/v1/users" do
    json({
      users: [
        {id: 1, name: "Alice"},
        {id: 2, name: "Bob"}
      ]
    })
  end
end

# Note: The following would cause compilation errors with -D lucky_no_html:
# 
# class HomePage < Lucky::HTMLPage
#   def render
#     h1 "This won't compile in API-only mode!"
#   end
# end

puts "API-only Lucky app example compiled successfully!"
puts "Available routes:"
puts "  GET /api/v1/status"
puts "  GET /api/v1/users"