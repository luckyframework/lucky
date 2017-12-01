require "colorize"
require "file_utils"

class Lucky::ActionGenerator < Teeplate::FileTree
  getter :name

  directory "#{__DIR__}"

  def initialize(@name : String)
  end

  def generate
    make_folders_if_missing
    File.write(filename, contents)
  end

  private def make_folders_if_missing
    FileUtils.mkdir_p Dir.current + "/src/actions/#{path}"
  end

  private def path_args
    name.split("::").map(&.downcase)
  end

  private def path
    path_args[0..-2].join("/")
  end

  private def action
    path_args.last
  end

  private def filename
    Dir.current + "/src/actions/#{path}/#{action}.cr"
  end

  private def contents
    to_s
  end
end

class Gen::Action < LuckyCli::Task
  banner "Generate a new action"
  error : String?

  def call(io : IO = STDOUT)
    if valid?
      Lucky::ActionGenerator.new(name: ARGV.first).generate
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
end
