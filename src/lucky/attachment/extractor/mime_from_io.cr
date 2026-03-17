struct Lucky::Attachment::Extractor::MimeFromIO
  include Lucky::Attachment::Extractor

  # Extracts the MIME type from the IO.
  def extract(uploaded_file, metadata, **options) : String?
    return unless type = uploaded_file.content_type
    return unless mime = type.split(';').first?.try(&.strip)
    return if mime.empty?

    mime if mime.matches?(/\A\w+\/[\w\.\+\-]+\z/)
  end
end
