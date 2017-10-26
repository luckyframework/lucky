require "./lucky_web"
require "./app/**"
require "colorize"

LuckyWeb::Server.configure do
  settings.secret_key_base = "super_secret"
end

LuckyWeb::Session::Store.configure do
  settings.key = "test_app"
  settings.secret = "super-secret"
end

server = HTTP::Server.new("127.0.0.1", 8080, [
  HTTP::ErrorHandler.new,
  HTTP::LogHandler.new,
  LuckyWeb::Flash::Handler.new,
  LuckyWeb::RouteHandler.new,
])

puts "Listening on http://127.0.0.1:8080...".colorize(:green)

# TODO: Make sure finishe macro works for rendering
server.listen
