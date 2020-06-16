struct RawLogFormatter < Dexter::BaseFormatter
  def call : Nil
    io << data
  end
end
