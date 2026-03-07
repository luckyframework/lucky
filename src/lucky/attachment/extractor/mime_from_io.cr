struct Lucky::Attachment::Extractor::MimeFromIO
  include Lucky::Attachment::Extractor

  # Extracts the MIME type from the IO.
  def extract(io, metadata, **options) : String?
    return unless io.responds_to?(:content_type) && (type = io.content_type)

    type.split(';').first.strip
  end
end
