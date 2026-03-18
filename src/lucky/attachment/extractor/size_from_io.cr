struct Lucky::Attachment::Extractor::SizeFromIO
  include Lucky::Attachment::Extractor

  # Tries to extract the file size from the IO.
  def extract(uploaded_file, metadata, **options) : Int64?
    uploaded_file.tempfile.size
  end
end
