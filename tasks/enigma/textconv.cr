require "lucky_cli"
require "./file"
require "./log"

class Enigma::Textconv < LuckyCli::Task
  include Log
  banner "Task used for textconv"

  def call
    log "------ Textconv"
    if filename = ARGV.first?
      log "Textconv for #{filename}"
      contents = ::File.read(filename)
      puts Enigma::File.new(contents).decrypt
    else
      log "No file for textconv"
    end
  end
end
