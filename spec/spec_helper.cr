require "spec"
require "../src/lucky"
require "../tasks/**"
require "./support/**"

Lucky::AssetHelpers.load_manifest

Spec.before_each do
  ARGV.clear
end

Log.dexter.configure(:none)

Lucky::Session.configure do |settings|
  settings.key = "_app_session"
end

Lucky::Server.configure do |settings|
  settings.secret_key_base = Random::Secure.base64(32)
  settings.host = "0.0.0.0"
  settings.port = 8080
end

Lucky::RouteHelper.configure do |settings|
  settings.base_uri = "luckyframework.org"
end

class UnusedDatabase < Avram::Database
end

UnusedDatabase.configure do |settings|
  settings.credentials = Avram::Credentials.void
end

Avram.configure do |settings|
  settings.database_to_migrate = UnusedDatabase
end

Lucky::ErrorHandler.configure do |settings|
  settings.show_debug_output = false
end

Lucky::ForceSSLHandler.configure do |settings|
  settings.enabled = true
end

Habitat.raise_if_missing_settings!
