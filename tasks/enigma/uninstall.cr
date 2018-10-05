require "lucky_cli"
require "./encrypted_files"
require "./setup"

class Enigma::Uninstall < LuckyCli::Task
  GIT_ATTRIBUTES = ".gitattributes"

  banner "Uninstall Enigma"

  # TODO: Only uninstall if it was installed previously
  def call
    remove_enigma_from_gitattributes
    remove_enigma_git_config
    force_checkout
    puts "Uninstalled Enigma"
  end

  private def force_checkout
    # Pretty much always do this I guess
    # this would normally delete uncommitted changes in the working directory,
    # but we already made sure the repo was clean during the safety checks

    # local encrypted_files=$(git ls-crypt)
    # cd "$REPO" || die 1 'could not change into the "%s" directory' "$REPO"
    # IFS=$'\n'
    # for file in $encrypted_files; do
    # 	rm "$file"
    # 	git checkout --force HEAD -- "$file" > /dev/null
    # done
    # unset IFS
    Enigma::EncryptedFiles.paths.each do |path|
      run %(git checkout --force HEAD -- #{path} > /dev/null)
    end
  end

  private def remove_enigma_from_gitattributes
    current_gitattributes = File.read(GIT_ATTRIBUTES)
    lines_without_enigma = [] of String

    current_gitattributes.each_line do |line|
      if !line.includes?("filter=enigma")
        lines_without_enigma << line
      end
    end

    FileUtils.rm(GIT_ATTRIBUTES)
    File.write(GIT_ATTRIBUTES, lines_without_enigma.join("\n"))
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
