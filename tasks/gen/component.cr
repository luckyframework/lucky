require "lucky_task"
require "lucky_template"
require "colorize"

class Lucky::ComponentTemplate
  @filename : String
  @class : String
  @output_path : Path

  def initialize(@filename, @class, @output_path)
  end

  def render(path : Path)
    LuckyTemplate.write!(path, template_folder)
  end

  def template_folder
    LuckyTemplate.create_folder do |root_dir|
      root_dir.add_file(Path["#{@output_path}/#{@filename}.cr"]) do |io|
        ECR.embed("#{__DIR__}/templates/component/component.cr.ecr", io)
      end
    end
  end
end

class Gen::Component < LuckyTask::Task
  summary "Generate a new HTML component"
  help_message <<-TEXT
  #{task_summary}

  Example:

    lucky gen.component SettingsMenu
  TEXT

  def call
    if error
      output.puts error.colorize(:red)
    else
      Lucky::ComponentTemplate.new(component_filename, component_class, output_path).render(output_path)
      output.puts success_message
    end
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
    Path["./src/components/#{parts.map(&.underscore.downcase).join('/')}"]
  end

  private def output_path_with_filename
    File.join(output_path, component_filename + ".cr")
  end

  private def success_message
    "Done generating #{component_class.colorize.green} in #{output_path_with_filename.colorize.green}"
  end
end
