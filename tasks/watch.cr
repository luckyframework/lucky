require "lucky_task"
require "option_parser"
require "colorize"
require "yaml"
require "http"
require "../src/lucky/server_settings"

# Based on the sentry shard with some modifications to output and build process.
module LuckySentry
  FILE_TIMESTAMPS = {} of String => String # {file => timestamp}

  # Base Watcher class
  abstract class Watcher
    abstract def start : Nil
    abstract def reload : Nil
    abstract def running? : Bool
    abstract def running_at : String?
  end

  # Watcher using WebSockets to reload browser
  class WebSocketWatcher < Watcher
    @captured_sockets = [] of HTTP::WebSocket
    @server : HTTP::Server

    def initialize
      handler = HTTP::WebSocketHandler.new do |socket|
        @captured_sockets << socket

        socket.on_close do
          @captured_sockets.delete(socket)
        end
      end
      @server = HTTP::Server.new([handler])
    end

    def start : Nil
      @server.bind_tcp(Lucky::ServerSettings.host, Lucky::ServerSettings.reload_port)
      spawn { @server.listen }
    end

    def reload : Nil
      @captured_sockets.each do |socket|
        socket.send("data: update")
        socket.close
      end
    end

    def running? : Bool
      @server.listening?
    end

    def running_at : Nil
    end
  end

  # Watcher using ServerSentEvents (SSE) to reload browser
  class ServerSentEventWatcher < Watcher
    @captured_contexts = [] of HTTP::Server::Context
    @server : HTTP::Server

    def initialize
      @server = HTTP::Server.new do |context|
        context.response.headers.merge!({
          "Access-Control-Allow-Origin" => "*",
          "Content-Type"                => "text/event-stream",
          "Connection"                  => "keep-alive",
          "Cache-Control"               => "no-cache",
        })
        context.response.status_code = 200

        @captured_contexts << context

        # SSE start
        loop do
          break if context.response.closed?
          sleep 0.1
        end
        # SSE stop
      end
    end

    def start : Nil
      @server.bind_tcp(Lucky::ServerSettings.host, Lucky::ServerSettings.reload_port)
      spawn { @server.listen }
    end

    def reload : Nil
      while context = @captured_contexts.shift?
        context.response.print "data: update\n\n"
        context.response.flush
        context.response.close
      end
    end

    def running? : Bool
      @server.listening?
    end

    def running_at : Nil
    end
  end

  # Watcher using browsersync to reload browser
  class BrowsersyncWatcher < Watcher
    @options : String
    @is_running : Bool = false

    def initialize
      host_url = "http://#{Lucky::ServerSettings.host}:#{Lucky::ServerSettings.port}"
      @options = ["-c", "bs-config.js", "--port", Lucky::ServerSettings.reload_port, "-p", host_url].join(" ")
    end

    def start : Nil
      spawn do
        Process.run \
          "RUNNING_IN_BROWSERSYNC=true yarn run browser-sync start #{@options}",
          output: STDOUT,
          error: STDERR,
          shell: true
      end
      @is_running = true
    end

    def reload : Nil
      if running?
        Process.run \
          "yarn run browser-sync reload --port #{Lucky::ServerSettings.reload_port}",
          output: STDOUT,
          error: STDERR,
          shell: true
      end
    end

    def running? : Bool
      @is_running
    end

    def running_at : String
      "http://#{Lucky::ServerSettings.host}:#{Lucky::ServerSettings.reload_port}"
    end
  end

  class ProcessRunner
    include LuckyTask::TextHelpers

    getter build_processes = [] of Process
    getter app_processes = [] of Process
    getter! watcher : Watcher
    property successful_compilations
    property app_built
    property? reload_browser

    @app_built : Bool = false
    @successful_compilations : Int32 = 0

    def initialize(@build_commands : Array(String), @run_commands : Array(String), @files : Array(String), @reload_browser : Bool, @watcher : Watcher?)
    end

    private def build_app_processes_and_start
      @build_processes.clear
      @build_commands.each do |command|
        @build_processes << Process.new(command, shell: true, output: STDOUT, error: STDERR)
      end
      build_processes_copy = @build_processes.dup
      spawn do
        build_statuses = build_processes_copy.map(&.wait)
        success = build_statuses.all?(&.success?)
        if build_processes == build_processes_copy # if this build was not aborted in #stop_all_processes
          start_all_processes(success)
        end
      end
    end

    private def create_app_processes
      @app_processes.clear
      @run_commands.each do |command|
        @app_processes << Process.new(command, shell: false, output: STDOUT, error: STDERR)
      end

      @successful_compilations += 1
      if reload_browser?
        reload_or_start_watcher
      end
      if @successful_compilations == 1
        spawn do
          sleep(0.3)
          print_running_at
        end
      end
    end

    private def reload_or_start_watcher
      if @successful_compilations == 1
        start_watcher
      else
        reload_watcher
      end
    end

    private def start_watcher
      watcher.start unless watcher.running?
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
        watcher.running_at || original_url
      else
        original_url
      end
    end

    private def original_url
      "http://#{Lucky::ServerSettings.host}:#{Lucky::ServerSettings.port}"
    end

    private def reload_watcher
      watcher.reload
    end

    private def get_timestamp(file : String)
      File.info(file).modification_time.to_s("%Y%m%d%H%M%S")
    end

    def restart_app
      build_in_progress = @build_processes.any?(&.exists?)
      stop_all_processes
      puts build_in_progress ? "Recompiling..." : "\nCompiling..."
      build_app_processes_and_start
    end

    private def stop_all_processes
      @build_processes.each do |process|
        unless process.terminated?
          # kill child process, because we started build process with shell option
          Process.run("pkill -P #{process.pid}", shell: true)
          process.terminate
        end
      end
      @app_processes.each do |process|
        process.terminate unless process.terminated?
      end
    end

    private def start_all_processes(build_success : Bool)
      if build_success
        self.app_built = true
        create_app_processes
        puts "#{" Done ".colorize.on_cyan.black} compiling"
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
          ▸  Ask for help: #{"https://luckyframework.org/chat".colorize.bold}
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

      restart_app if file_changed # (file_changed || app_processes.empty?)
    end
  end
end

class Watch < LuckyTask::Task
  summary "Start and recompile project when files change"
  switch :error_trace, "Show full error trace"

  switch :reload_browser, "Reloads browser on changes",
    shortcut: "-r"

  arg :watcher, "Watcher type for reloading browser",
    shortcut: "-w",
    optional: true,
    format: /(sse|browsersync)/

  def call
    build_commands = %w(crystal build ./src/start_server.cr -o bin/start_server)
    files = ["./src/**/*.cr", "./src/**/*.ecr", "./config/**/*.cr", "./shard.lock"]
    watcher_class = nil

    if reload_browser?
      case watcher
      when "sse"
        build_commands << "-Dlivereloadsse"
        watcher_class = LuckySentry::ServerSentEventWatcher.new
        files.concat(Lucky::ServerSettings.reload_watch_paths)
      when "browsersync"
        watcher_class = LuckySentry::BrowsersyncWatcher.new
      else
        build_commands << "-Dlivereloadws"
        watcher_class = LuckySentry::WebSocketWatcher.new
        files.concat(Lucky::ServerSettings.reload_watch_paths)
      end
    end

    build_commands << "--error-trace" if error_trace?
    build_commands = [build_commands.join(" ")]
    run_commands = %w(./bin/start_server)

    process_runner = LuckySentry::ProcessRunner.new(
      files: files,
      build_commands: build_commands,
      run_commands: run_commands,
      reload_browser: reload_browser?,
      watcher: watcher_class
    )

    puts "Beginning to watch your project"

    loop do
      process_runner.scan_files
      sleep 0.1
    end
  end
end
