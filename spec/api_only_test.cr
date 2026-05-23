# This file tests that Lucky can be compiled without HTML functionality
# Run with: crystal build spec/api_only_test.cr -D lucky_no_html

require "../src/lucky"

# Test API action without HTML
class Api::Users::Index < Lucky::Action
  get "/api/users" do
    json({users: ["alice", "bob"]})
  end
end

# This should work in API-only mode
puts "API-only compilation successful!"

# The following would fail with lucky_no_html flag:
# class TestPage
#   include Lucky::HTMLPage
# end