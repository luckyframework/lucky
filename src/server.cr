require "./lucky"
require "./app/**"
require "colorize"

Lucky::Server.configure do
  settings.secret_key_base = "super_secret"
end

Lucky::Session::Store.configure do
  settings.key = "test_app"
  settings.secret = "super-secret"
end

server = HTTP::Server.new("127.0.0.1", 8080, [
  Lucky::LogHandler.new,
  Lucky::ErrorHandler.new(action: ErrorAction),
  Lucky::Flash::Handler.new,
  Lucky::RouteHandler.new,
])

puts "Listening on http://127.0.0.1:8080...".colorize(:green)

# TODO: Make sure finishe macro works for rendering
server.listen
