struct RawLogFormatter < Dexter::Formatters::BaseLogFormatter
  def format(data)
    io << data
  end
end
