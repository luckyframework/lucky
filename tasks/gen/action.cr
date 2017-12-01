require "colorize"
require "ecr"
require "file_utils"

class Lucky::ActionGenerator
  getter :name

  ECR.def_to_s "#{__DIR__}/action.ecr"

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

  def call(io : IO = STDOUT)
    if ARGV.first?.nil?
      io.puts "Action name is required. Example: lucky gen.action Users::Index".colorize(:red)
    else
      Lucky::ActionGenerator.new(name: ARGV.first).generate
    end
  end
end
