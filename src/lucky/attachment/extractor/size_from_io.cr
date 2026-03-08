struct Lucky::Attachment::Extractor::SizeFromIO
  include Lucky::Attachment::Extractor

  # Tries to extract the file size from the IO.
  def extract(io, metadata, **options) : Int64?
    if io.responds_to?(:tempfile)
      io.tempfile.size
    elsif io.responds_to?(:size)
      io.size.to_i64
    end
  end
end
