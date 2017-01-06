require "option_parser"
require "colorize"

module Sentry
  FILE_TIMESTAMPS = {} of String => String # {file => timestamp}

  class ProcessRunner
    getter app_processes = [] of Process

    def initialize(build_commands : Array(String), run_commands : Array(String), files)
      @app_built = false
      @build_commands = build_commands
      @run_commands = run_commands
      @files = [] of String
      @files = files
    end

    private def build_app_processes
      @build_commands.map do |command|
        Process.run(command, shell: true, output: true, error: true)
      end
    end

    private def create_app_processes
      @app_processes.clear
      @run_commands.each do |command|
        @app_processes << Process.new(command, shell: true, output: true, error: true)
      end
    end

    private def get_timestamp(file : String)
      File.stat(file).mtime.to_s("%Y%m%d%H%M%S")
    end

    def start_app
      @app_processes.each do |process|
        process.kill unless process.terminated?
      end

      puts "🤖  compiling..."
      build_result = build_app_processes()
      if build_result.all? &.success?
        @app_built = true
        create_app_processes()
      elsif !@app_built # if build fails on first time compiling, then exit
        puts "🤖  Compile time errors detected. SentryBot shutting down...".colorize(:red)
        exit 1
      end
    end

    def scan_files
      file_changed = false
      app_processes = @app_processes
      files = @files
      Dir.glob(files) do |file|
        timestamp = get_timestamp(file)
        if FILE_TIMESTAMPS[file]? && FILE_TIMESTAMPS[file] != timestamp
          FILE_TIMESTAMPS[file] = timestamp
          file_changed = true
          puts "🤖  #{file} has changed".colorize(:yellow)
        elsif FILE_TIMESTAMPS[file]?.nil?
          FILE_TIMESTAMPS[file] = timestamp
          file_changed = true if (app_processes.none? &.terminated?)
        end
      end

      start_app() if (file_changed || app_processes.empty?)
    end
  end
end

class Watch < LuckyCli::Task
  banner "watch it"

  def call
    build_commands = ["crystal build ./src/server.cr"]
    run_commands = ["./server"]
    files = ["./src/**/*.cr", "./src/**/*.ecr"]
    files_cleared = false
    show_help = false

    OptionParser.parse! do |parser|
      parser.banner = "Usage: ./sentry [options]"
      parser.on(
        "-r RUN_COMMAND",
        "--run=RUN_COMMAND",
        "Overrides the default run command") { |command| run_commands = [command] }
      parser.on(
        "-b BUILD_COMMAND",
        "--build=BUILD_COMMAND",
        "Overrides the default build command") { |command| build_commands = [command] }
      parser.on(
        "-w FILE",
        "--watch=FILE",
        "Overrides default files and appends to list of watched files") do |file|
        unless files_cleared
          files.clear
          files_cleared = true
        end
        files << file
      end
      parser.on(
        "-i",
        "--info",
        "Shows the values for build command, run command, and watched files") do
        puts "
      build: \t#{build_commands}
      run: \t#{run_commands}
      files: \t#{files}
    "
      end
      parser.on(
        "-h",
        "--help",
        "Show this help") do
        puts parser
        exit 0
      end
    end

    process_runner = Sentry::ProcessRunner.new(
      files: files,
      build_commands: build_commands,
      run_commands: run_commands
    )

    puts "🤖  Your SentryBot is vigilant. beep-boop..."

    loop do
      process_runner.scan_files
      sleep 0.1
    end
  end
end
