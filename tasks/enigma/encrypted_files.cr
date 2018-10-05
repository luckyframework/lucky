class Enigma::EncryptedFiles
  def self.paths : Array(String)
    `git ls-files | git check-attr --stdin filter | awk 'BEGIN { FS = ":" }; /enigma$/{ print $1 }'`
      .split("\n")
  end
end
