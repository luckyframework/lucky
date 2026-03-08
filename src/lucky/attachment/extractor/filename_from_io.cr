struct Lucky::Attachment::Extractor::FilenameFromIO
  include Lucky::Attachment::Extractor

  # Returns the filename from the options or tries to extract the filename from
  # the IO object.
  def extract(io, metadata, **options) : String?
    options[:filename]? || if io.responds_to?(:original_filename)
      io.original_filename
    elsif io.responds_to?(:filename)
      io.filename.presence
    elsif io.responds_to?(:path)
      File.basename(io.path)
    end
  end
end
