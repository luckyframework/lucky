require "spec"
require "../src/lucky"
require "../tasks/**"
require "./support/**"

include RoutesHelper

Pulsar.enable_test_mode!

Lucky::AssetHelpers.load_manifest

Spec.before_each do
  ARGV.clear
end

Log.dexter.configure(:none)

Lucky::Session.configure do |settings|
  settings.key = "_app_session"
end

Lucky::Server.configure do |settings|
  settings.secret_key_base = "EPzB4/PA/JZxEhISPr7Ad5X+G73exX+qg8IKFjqwdx0="
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

LuckyCache.configure do |settings|
  settings.storage = LuckyCache::MemoryStore.new
end

Habitat.raise_if_missing_settings!
