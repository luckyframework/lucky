require "lucky_task"

class Gen::SecretKey < LuckyTask::Task
  summary "Generate a new secret key"

  int32 :number, "n random bytes used to encode into base64.", shortcut: "-n", default: 32

  def call
    output.puts Random::Secure.base64(number)
  end
end
