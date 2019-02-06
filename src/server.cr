require "./lucky"
require "./app/**"
require "colorize"

Lucky::Server.configure do |settings|
  settings.secret_key_base = "super_secret"
end

Lucky::Session::Store.configure do |settings|
  settings.key = "test_app"
  settings.secret = "super-secret"
end

server = HTTP::Server.new([
  Lucky::LogHandler.new,
  Lucky::ErrorHandler.new(action: ErrorAction),
  Lucky::Flash::Handler.new,
  Lucky::RouteHandler.new,
])

Lucky::RouteHelper.configure do |settings|
  settings.base_uri = "some_value"
end

Avram::Repo.configure do |settings|
  settings.url = ""
end

Lucky::StaticFileHandler.configure do |settings|
  settings.hide_from_logs = true
end

Lucky::ErrorHandler.configure do |settings|
  settings.show_debug_output = true
end

Lucky::LogHandler.configure do |settings|
  settings.show_timestamps = false
end

Lucky::Server.configure do |settings|
  settings.host = "0.0.0.0"
  settings.port = 8080
end

Habitat.raise_if_missing_settings!

puts "Listening on http://127.0.0.1:8080...".colorize(:green)

server.listen(8080)
