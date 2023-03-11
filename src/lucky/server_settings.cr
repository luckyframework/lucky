require "yaml"

module Lucky::ServerSettings
  YAML_SETTINGS_PATH = "./config/watch.yml"

  extend self

  # The host for your local development.
  # Depending on your setup, you may need `localhost`, `127.0.0.1`, or `0.0.0.0`
  def host : String
    ENV["DEV_HOST"]? || settings["host"].as_s
  end

  # The port to run your local dev server
  def port : Int32
    ENV["DEV_PORT"]?.try(&.to_i) || settings["port"].as_i
  end

  # This is the port the dev watcher service will run on
  def reload_port : Int32
    ENV["RELOAD_PORT"]?.try(&.to_i) || settings["reload_port"]?.try(&.as_i) || 3001
  end

  # Watch additional paths for changes
  def reload_watch_paths : Array(String)
    settings["extra_watch_paths"]?.try(&.as_a.map(&.as_s)) || [] of String
  end

  @@__settings : YAML::Any? = nil

  private def settings : YAML::Any
    if @@__settings.nil?
      @@__settings = YAML.parse(yaml_settings_file)
    else
      @@__settings.as(YAML::Any)
    end
  end

  private def yaml_settings_file
    if File.exists?(YAML_SETTINGS_PATH)
      File.read YAML_SETTINGS_PATH
    else
      raise "Expected config file for the watcher at #{YAML_SETTINGS_PATH}"
    end
  end
end
