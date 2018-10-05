require "lucky_cli"
require "colorize"

class Build::Release < LuckyCli::Task
  include LuckyCli::TextHelpers

  banner "Compile app for production"

  def call
    command = "crystal build --release src/server.cr"

    log "Building binary with '#{command}"
    process = Process.run(command, shell: true, output: STDOUT, error: STDERR)
    if process.success?
      log "Build succeeded - binary saved at './server'"
    end
  end

  def log(message)
    puts "  #{green_arrow} #{message}"
  end
end
