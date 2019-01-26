require "lucky_cli"
require "option_parser"
require "colorize"
require "yaml"
require "../src/lucky/server_settings"
require "option_parser"

# Based on the sentry shard with some modifications to outut and build process.
module Sentry
  FILE_TIMESTAMPS  = {} of String => String # {file => timestamp}
  BROWSERSYNC_PORT = 3001

  class ProcessRunner
    include LuckyCli::TextHelpers

    getter app_processes = [] of Process
    property successful_compilations
    property app_built
    property? reload_browser

    @app_built : Bool = false
    @successful_compilations : Int32 = 0

    def initialize(build_commands : Array(String), run_commands : Array(String), files : Array(String), @reload_browser : Bool)
      @build_commands = build_commands
      @run_commands = run_commands
      @files = files
    end

    private def build_app_processes
      @build_commands.map do |command|
        Process.run(command, shell: true, output: STDOUT, error: STDERR)
      end
    end

    private def create_app_processes
      @app_processes.clear
      @run_commands.each do |command|
        @app_processes << Process.new(command, shell: false, output: STDOUT, error: STDERR)
      end

      self.successful_compilations += 1
      if reload_browser?
        reload_or_start_browser_sync
      end
    end

    private def reload_or_start_browser_sync
      if successful_compilations == 1
        if browsersync_port_is_available?
          start_browsersync
        else
          print_browsersync_port_taken_error
        end
      else
        reload_browsersync
      end
    end

    private def browsersync_port_is_available? : Bool
      if File.executable?(`which lsof`.chomp)
        io = IO::Memory.new
        Process.run("lsof -i :#{BROWSERSYNC_PORT}", output: io, error: STDERR, shell: true)
        io.to_s.empty?
      else
        true
      end
    end

    private def print_browsersync_port_taken_error
      io = IO::Memory.new
      Process.run("ps -p `lsof -ti :#{BROWSERSYNC_PORT}` -o command", output: io, error: STDERR, shell: true)
      puts "There was a problem starting browsersync. Port #{BROWSERSYNC_PORT} is in use.".colorize(:red)
      puts <<-ERROR

      Try closing these programs...

        #{io.to_s}
      ERROR
    end

    private def start_browsersync
      spawn do
        Process.run "RUNNING_IN_BROWSERSYNC=true yarn run browser-sync start #{browsersync_options}",
          output: STDOUT,
          error: STDERR,
          shell: true
      end
    end

    private def browsersync_options
      "-c bs-config.js --port #{BROWSERSYNC_PORT} -p #{proxy}"
    end

    private def proxy
      "http://#{Lucky::ServerSettings.host}:#{Lucky::ServerSettings.port}"
    end

    private def reload_browsersync
      Process.run "yarn run browser-sync reload --port #{BROWSERSYNC_PORT}",
        output: STDOUT,
        error: STDERR,
        shell: true
    end

    private def get_timestamp(file : String)
      File.info(file).modification_time.to_s("%Y%m%d%H%M%S")
    end

    def start_app
      stop_all_processes
      puts "compiling..."
      start_all_processes
    end

    private def stop_all_processes
      @app_processes.each do |process|
        process.kill unless process.terminated?
      end
    end

    private def start_all_processes
      if build_app_processes.all? &.success?
        self.app_built = true
        create_app_processes()
      elsif !app_built
        print_error_message
      end
    end

    private def print_error_message
      puts "There was a problem compiling. Watching for fixes...".colorize(:red)
      if successful_compilations.zero?
        puts <<-ERROR

        Try this...

          #{green_arrow} If you haven't done it already, run #{"bin/setup".colorize(:green)}
          #{green_arrow} Run #{"shards install".colorize(:green)} to ensure dependencies are installed
          #{green_arrow} Ask for help in #{"https://gitter.im/luckyframework/Lobby".colorize(:green)}
        ERROR
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
          puts "#{file} has changed".colorize(:yellow)
        elsif FILE_TIMESTAMPS[file]?.nil?
          FILE_TIMESTAMPS[file] = timestamp
          file_changed = true if (app_processes.none? &.terminated?)
        end
      end

      start_app() if file_changed # (file_changed || app_processes.empty?)
    end
  end
end

class Watch < LuckyCli::Task
  summary "Start and recompile project when files change"
  @reload_browser : Bool = false

  def call
    parse_options

    build_commands = ["crystal build ./src/server.cr"]
    run_commands = ["./server"]
    files = ["./src/**/*.cr", "./src/**/*.ecr", "./config/**/*.cr", "./shard.lock"]

    process_runner = Sentry::ProcessRunner.new(
      files: files,
      build_commands: build_commands,
      run_commands: run_commands,
      reload_browser: @reload_browser
    )

    puts "Beginnning to watch your project"

    loop do
      process_runner.scan_files
      sleep 0.1
    end
  end

  private def parse_options
    OptionParser.parse! do |parser|
      parser.banner = "Usage: lucky watch [arguments]"
      parser.on("-r", "--reload-browser", "Reloads browser on changes using browser-sync") {
        @reload_browser = true
      }
      parser.on("-h", "--help", "Help here") {
        puts parser
        exit(0)
      }
    end
  end
end
