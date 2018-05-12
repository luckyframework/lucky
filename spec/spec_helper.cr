require "spec"
{% unless flag?("without-migrator") %}
require "lucky_migrator"
{% end %}
require "../src/lucky"
require "../tasks/**"
require "./support/**"

Lucky::Session::Store.configure do
  settings.key = "test_app"
  settings.secret = "super-secret"
end

Lucky::Server.configure do
  settings.secret_key_base = "super-secret"
  settings.host = "0.0.0.0"
  settings.port = 8080
end

Lucky::RouteHelper.configure do
  settings.base_uri = "luckyframework.org"
end

LuckyRecord::Repo.configure do
  settings.url = "Not used yet"
end

macro configure_migrator(lucky_migrator)
  {% if lucky_migrator.resolve? %}
    LuckyMigrator::Runner.configure do
      settings.database = "doesn't matter"
    end
  {% end %}
end

configure_migrator(LuckyMigrator)

Lucky::ErrorHandler.configure do
  settings.show_debug_output = false
end

Lucky::LogHandler.configure do
  settings.show_timestamps = false
end

Lucky::StaticFileHandler.configure do
  settings.hide_from_logs = true
end

Habitat.raise_if_missing_settings!
