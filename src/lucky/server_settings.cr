require "yaml"

module Lucky::ServerSettings
  YAML_SETTINGS_PATH = "./config/watch.yml"

  extend self

  def host : String
    settings["host"].as_s
  end

  def port : Int32
    ENV["DEV_PORT"]?.try(&.to_i) || settings["port"].as_i
  end

  private def settings
    YAML.parse(yaml_settings_file)
  end

  private def yaml_settings_file
    if File.exists?(YAML_SETTINGS_PATH)
      File.read YAML_SETTINGS_PATH
    else
      raise "Expected config file for the watcher at #{YAML_SETTINGS_PATH}"
    end
  end
end
