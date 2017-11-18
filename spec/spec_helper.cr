require "spec"
require "../src/lucky_web"
require "../tasks/**"
require "./support/**"

LuckyWeb::Session::Store.configure do
  settings.key = "test_app"
  settings.secret = "super-secret"
end

LuckyWeb::Server.configure do
  settings.secret_key_base = "super-secret"
end

LuckyRecord::Repo.configure do
  settings.url = "Not used yet"
end

LuckyWeb::ErrorHandler.configure do
  settings.show_debug_output = false
end

LuckyWeb::LogHandler.configure do
  settings.show_timestamps = false
end

LuckyWeb::StaticFileHandler.configure do
  settings.hide_from_logs = true
end

Habitat.raise_if_missing_settings!
