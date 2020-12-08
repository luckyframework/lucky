require "lucky_cli"
require "option_parser"
require "colorize"
require "yaml"
require "../src/lucky/server_settings"
require "option_parser"

# Based on the sentry shard with some modifications to output and build process.
module LuckySentry
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
      if successful_compilations == 1
        spawn do
          sleep(0.3)
          print_running_at
        end
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

        #{io}
      ERROR
    end

    private def start_browsersync
      spawn do
        Process.run \
          "RUNNING_IN_BROWSERSYNC=true yarn run browser-sync start #{browsersync_options}",
          output: STDOUT,
          error: STDERR,
          shell: true
      end
    end

    private def print_running_at
      STDOUT.puts ""
      STDOUT.puts running_at_background
      STDOUT.puts running_at_message.colorize.on_cyan.black
      STDOUT.puts running_at_background
      STDOUT.puts ""
    end

    private def running_at_background
      extra_space_for_emoji = 1
      (" " * (running_at_message.size + extra_space_for_emoji)).colorize.on_cyan
    end

    private def running_at_message
      "   🎉 App running at #{running_at}   "
    end

    private def running_at
      if reload_browser?
        browsersync_url
      else
        original_url
      end
    end

    private def browsersync_options
      "-c bs-config.js --port #{BROWSERSYNC_PORT} -p #{original_url}"
    end

    private def browsersync_url
      "http://#{Lucky::ServerSettings.host}:#{BROWSERSYNC_PORT}"
    end

    private def original_url
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
      puts "Compiling..."
      start_all_processes
    end

    private def stop_all_processes
      @app_processes.each do |process|
        process.signal(:term) unless process.terminated?
      end
    end

    private def start_all_processes
      if build_app_processes.all? &.success?
        self.app_built = true
        create_app_processes()
        puts "Done compiling"
      elsif !app_built
        print_error_message
      end
    end

    private def print_error_message
      if successful_compilations.zero?
        puts <<-ERROR

        #{"---".colorize.dim}

        Feeling stuck? Try this...

          ▸  Run setup: #{"script/setup".colorize.bold}
          ▸  Reinstall shards: #{"rm -rf lib bin && shards install".colorize.bold}
          ▸  Ask for help: #{"https://discord.gg/HeqJUcb".colorize.bold}
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
  switch :reload_browser, "Reloads browser on changes using browser-sync", shortcut: "-r"
  switch :error_trace, "Show full error trace"

  def call
    build_commands = ["crystal build ./src/start_server.cr -o bin/start_server"]
    build_commands[0] += " --error-trace" if error_trace?
    run_commands = ["./bin/start_server"]
    files = ["./src/**/*.cr", "./src/**/*.ecr", "./config/**/*.cr", "./shard.lock"]

    process_runner = LuckySentry::ProcessRunner.new(
      files: files,
      build_commands: build_commands,
      run_commands: run_commands,
      reload_browser: reload_browser?
    )

    puts "Beginning to watch your project"

    loop do
      process_runner.scan_files
      sleep 0.1
    end
  end
end
