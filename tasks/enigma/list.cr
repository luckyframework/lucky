class Enigma::List < LuckyCli::Task
  banner "List files being encrypted by Enigma"

  def call
    puts paths_to_encrypted_files
  end

  private def paths_to_encrypted_files
    `git ls-files | git check-attr --stdin filter | awk 'BEGIN { FS = ":" }; /enigma$/{ print $1 }'`
  end
end
