require "ecr"
require "lucky_task"
require "lucky_template"
require "colorize"

class Lucky::PageTemplate
  @page_filename : String
  @page_class : String
  @output_path : Path

  def initialize(@page_filename, @page_class, @output_path)
  end

  def render(path : Path)
    LuckyTemplate.write!(path, template_folder)
  end

  def template_folder
    LuckyTemplate.create_folder do |root_dir|
      root_dir.add_file(Path["#{@output_path}/#{@page_filename}.cr"]) do |io|
        ECR.embed("#{__DIR__}/templates/page/page.cr.ecr", io)
      end
    end
  end
end

class Gen::Page < LuckyTask::Task
  summary "Generate a new HTML page"
  help_message <<-TEXT
  #{task_summary}

  Example:

    lucky gen.page Users::IndexPage
  TEXT

  positional_arg :page_class, "The name of the page"

  def call
    if error
      output.puts error.colorize(:red)
    else
      Lucky::PageTemplate.new(page_filename, page_class, output_path).render(Path["."])
      output.puts success_message
    end
  end

  private def error
    missing_name_error || invalid_page_format_error
  end

  private def missing_name_error
    if page_class.nil?
      "Page name is required."
    end
  end

  private def invalid_page_format_error
    if !page_class.includes?("::") || !page_class.ends_with?("Page")
      "That's not a valid Page. Example: lucky gen.page Users::IndexPage"
    end
  end

  private def page_filename
    page_class.split("::").last.underscore.downcase
  end

  private def output_path
    page_parts = page_class.split("::")
    page_parts.pop
    Path["./src/pages/#{page_parts.map(&.underscore.downcase).join('/')}"].normalize
  end

  private def output_path_with_filename
    File.join(output_path, page_filename + ".cr")
  end

  private def success_message
    "Done generating #{page_class.colorize.green} in #{output_path_with_filename.colorize.green}"
  end
end
