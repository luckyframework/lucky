struct Lucky::Attachment::Extractor::MimeFromExtension
  include Lucky::Attachment::Extractor

  # Extracts the MIME type from the extension of the filename.
  def extract(io, metadata, **options) : String?
    return unless filename = FilenameFromIO.new.extract(io, metadata, **options)

    MIME.from_filename(filename)
  rescue KeyError
    nil
  end
end
