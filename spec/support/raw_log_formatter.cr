struct RawLogFormatter < Dexter::Formatters::BaseLogFormatter
  def format(data) : Nil
    io << data
  end
end
