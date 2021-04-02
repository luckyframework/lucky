require "lucky_cli"
require "colorize"

class Build::Release < LuckyCli::Task
  include LuckyCli::TextHelpers

  summary "Compile app for production"

  property error_io : IO = STDERR

  def call
    command = "crystal build --release src/start_server.cr -o bin/start_server"

    log "Building binary with '#{command}"
    process = Process.run(command, shell: true, output: output, error: error_io)
    if process.success?
      log "Build succeeded - binary saved at './bin/start_server'"
    end
  end

  def log(message)
    output.puts "  #{green_arrow} #{message}"
  end
end
