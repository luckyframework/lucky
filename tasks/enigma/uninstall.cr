require "lucky_cli"
require "./setup"

class Enigma::Uninstall < LuckyCli::Task
  banner "Uninstall Enigma"

  # TODO: Only uninstall if it was installed previously
  def call
    remove_enigma_from_gitattributes
    remove_enigma_git_config

    puts "Uninstalled Enigma"
  end

  private def remove_enigma_from_gitattributes
    current_gitattributes = File.read(".gitattributes")
    lines_without_enigma = [] of String

    current_gitattributes.each_line do |line|
      if !line.includes?("filter=enigma")
        lines_without_enigma << line
      end
    end

    File.write(".gitattributes", lines_without_enigma.join("\n"))
  end

  private def remove_enigma_git_config
    git_config_keys.each do |key|
      run %(git config --unset #{key})
    end
  end

  private def git_config_keys
    [Enigma::Setup::GIT_CONFIG_PATH_TO_KEY] + Enigma::Setup::GIT_CONFIG.keys
  end

  private def run(command, io = STDOUT)
    Process.run(command, shell: true, output: io, error: STDERR)
  end
end
