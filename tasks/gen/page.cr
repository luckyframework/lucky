require "lucky_task"
require "teeplate"
require "colorize"
require "file_utils"

class Lucky::PageTemplate < Teeplate::FileTree
  @page_filename : String
  @page_class : String
  @output_path : String

  directory "#{__DIR__}/templates/page"

  def initialize(@page_filename, @page_class, @output_path)
  end
end

class Gen::Page < LuckyTask::Task
  summary "Generate a new HTML page"

  def call(io : IO = STDOUT)
    if error
      io.puts error.colorize(:red)
    else
      Lucky::PageTemplate.new(page_filename, page_class, output_path).render(output_path)
      io.puts success_message
    end
  end

  def help_message
    <<-TEXT
    #{summary}

    Example:

      lucky gen.page Users::IndexPage
    TEXT
  end

  private def error
    missing_name_error || invalid_page_format_error
  end

  private def missing_name_error
    if ARGV.first?.nil?
      "Page name is required."
    end
  end

  private def invalid_page_format_error
    if !page_class.includes?("::") || !page_class.ends_with?("Page")
      "That's not a valid Page. Example: lucky gen.page Users::IndexPage"
    end
  end

  private def page_class
    ARGV.first
  end

  private def page_filename
    page_class.split("::").last.underscore.downcase
  end

  private def output_path
    page_parts = page_class.split("::")
    page_parts.pop
    "./src/pages/#{page_parts.map(&.underscore).map(&.downcase).join("/")}"
  end

  private def output_path_with_filename
    File.join(output_path, page_filename + ".cr")
  end

  private def success_message
    "Done generating #{page_class.colorize.green} in #{output_path_with_filename.colorize.green}"
  end
end
