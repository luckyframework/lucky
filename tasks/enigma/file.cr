require "./setup"
require "openssl/hmac"

class Enigma::File
  CIPHER = "-aes-256-cbc"
  private getter contents, key

  def initialize(@contents : String, @key : String = key_from_enigma)
  end

  def encrypt : String
    if encrypted?
      contents
    else
      command = %(openssl enc #{CIPHER} -pass pass:'#{key}' -S #{salt} -a)
      result = run(command, input_content: contents)
      result
    end
  end

  private def encrypted?
    contents.starts_with?("U2FsdGVk")
  end

  def decrypt : String
    if encrypted?
      FileUtils.mkdir_p "tmp"
      ::File.write "tmp/enigma_contents", contents + "\n"
      command = %(openssl enc #{CIPHER} -d -pass pass:'#{key}' -a -in tmp/enigma_contents)
      result = run command, input_content: ""
      result
    else
      contents
    end
    # rescue
    #   contents
  end

  private def salt
    OpenSSL::HMAC.hexdigest(algorithm: :sha256, key: key, data: contents)[-16..-1]
  end

  private def key_from_enigma : String
    `git config #{Enigma::Setup::GIT_CONFIG_PATH_TO_KEY}`
  end

  private def run(command, input_content : String) : String
    input = IO::Memory.new(input_content)
    output = IO::Memory.new
    result = Process.run(command, shell: true, input: input, output: output, error: STDERR)
    if result.success?
      output.to_s.chomp
    else
      ::File.write "failure", "#{Time.now} - Failed to run #{command}"
      raise "Failed to run OpenSSL command. Exited with: #{result.exit_code}"
    end
  end
end
