require "colorize"
require "file_utils"

class Lucky::ActionTemplate < Teeplate::FileTree
  @name : String
  @action : String

  directory "#{__DIR__}/templates"

  def initialize(@name, @action)
  end
end

class Gen::Action < LuckyCli::Task
  banner "Generate a new action"

  def call(io : IO = STDOUT)
    if valid?
      Lucky::ActionTemplate.new(action_name, action).render(output_path)
      io.puts success_message
    else
      io.puts @error.colorize(:red)
    end
  end

  private def valid?
    name_is_present && name_matches_format
  end

  private def name_is_present
    @error = "Action name is required. Example: lucky gen.action Users::Index"
    ARGV.first?
  end

  private def name_matches_format
    @error = "That's not a valid Action.  Example: lucky gen.action Users::Index"
    ARGV.first.includes?("::")
  end

  private def action_name
    ARGV.first
  end

  private def action
    path_args.last
  end

  private def output_path
    Dir.current + app_directory_path
  end

  private def app_directory_path
    "/src/actions/#{path}"
  end

  private def path
    path_args[0..-2].join("/")
  end

  private def path_args
    action_name.split("::").map(&.downcase)
  end

  private def success_message
    "Done generating #{action_name.colorize(:green)} in #{output_path.colorize(:green)}"
  end
end
