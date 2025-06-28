class Lucky::HTTP2::ResponseIO < IO
  private getter response : HT2::Response

  def initialize(@response : HT2::Response)
  end

  def write(slice : Bytes) : Nil
    response.write(slice)
  end

  def read(slice : Bytes)
    raise "Not implemented"
  end

  def flush
    # No-op
  end

  def close
    # No-op
  end
end
