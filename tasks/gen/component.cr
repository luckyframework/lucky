require "lucky_task"
require "teeplate"
require "colorize"
require "file_utils"

class Lucky::ComponentTemplate < Teeplate::FileTree
  @filename : String
  @class : String

  directory "#{__DIR__}/templates/component"

  def initialize(@filename, @class)
  end
end

class Gen::Component < LuckyTask::Task
  summary "Generate a new HTML component"

  def call(io : IO = STDOUT)
    if error
      io.puts error.colorize(:red)
    else
      Lucky::ComponentTemplate.new(component_filename, component_class).render(output_path)
      io.puts success_message
    end
  end

  def help_message
    <<-TEXT
    #{summary}

    Example:

      lucky gen.component SettingsMenu
    TEXT
  end

  private def error
    missing_name_error || invalid_format_error
  end

  private def missing_name_error
    if ARGV.first?.nil?
      "Component name is required."
    end
  end

  private def invalid_format_error
    if component_class.camelcase != component_class
      "Component name should be camel case. Example: lucky gen.component #{component_class.camelcase}"
    end
  end

  private def component_class
    ARGV.first
  end

  private def component_filename
    component_class.split("::").last.underscore.downcase
  end

  private def output_path
    parts = component_class.split("::")
    parts.pop
    "./src/components/#{parts.map(&.underscore).map(&.downcase).join("/")}"
  end

  private def output_path_with_filename
    File.join(output_path, component_filename + ".cr")
  end

  private def success_message
    "Done generating #{component_class.colorize.green} in #{output_path_with_filename.colorize.green}"
  end
end
