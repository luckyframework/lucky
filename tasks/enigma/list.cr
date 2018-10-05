require "./encrypted_files"

class Enigma::List < LuckyCli::Task
  banner "List files being encrypted by Enigma"

  def call
    puts Engima::EncryptedFiles.paths
  end
end
