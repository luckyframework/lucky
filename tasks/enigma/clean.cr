require "lucky_cli"
require "./file_contents"
require "./log"

# https://www.juandebravo.com/2017/12/02/git-filter-smudge-and-clean
# https://git-scm.com/book/en/v2/Customizing-Git-Git-Attributes
class Enigma::Clean < LuckyCli::Task
  include Log

  banner "Task used for git clean on checkin (file encryption)"

  def call
    log "------ Cleaning"
    if filename
      contents = STDIN.gets_to_end.to_s.chomp
      log "filename given (#{filename}) so encrypting/cleaning contents: #{contents}"
      STDOUT.puts Enigma::FileContents.new(contents).encrypt
    else
      log "no filename given for clean"
    end
  end

  private def filename : String?
    ARGV.first?
  end
end
