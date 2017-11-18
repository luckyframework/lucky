require "lucky_cli"

class Gen::SecretKey < LuckyCli::Task
  banner "Generate a new secret key"

  def call(io : IO = STDOUT)
    io.puts SecureRandom.base64(32)
  end
end
