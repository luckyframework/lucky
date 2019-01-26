require "cry"
require "option_parser"
require "habitat"
require "lucky_cli"

class Lucky::Exec < LuckyCli::Task
  name "exec"
  summary "Execute code. Use this in place of a console/REPL"

  Habitat.create do
    setting editor : String = "vim"
    setting template_path : String = "#{__DIR__}/exec_template.cr.template"
  end

  def call(args = ARGV)
    editor = settings.editor
    repeat = false
    back = 0

    OptionParser.parse(args) do |parser|
      parser.banner = "Usage: lucky exec [arguments]"
      parser.on("-h", "--help", "Show this help message") { puts parser; exit(0) }
      parser.on("-e EDITOR", "--editor EDITOR", "Which editor to use") do |e|
        editor = e
      end
      parser.on("-r", "--repeat", "Keep editing in a loop") do
        repeat = true
      end
      parser.on("-b BACK", "--back BACK", "Keep editing in a loop") do |b|
        back = b.to_i
      end
      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        STDERR.puts parser
        exit(1)
      end
      parser.missing_option do |option|
        STDERR.puts "ERROR: #{option} is missing a value"
        exit(1)
      end
    end

    Cry::CodeRunner.new(
      code: "",
      editor: editor,
      repeat: repeat,
      back: back,
      template: settings.template_path
    ).run
  end
end
