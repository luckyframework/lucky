require "./run_command"

struct Lucky::Attachment::Extractor::MimeFromFile
  include Lucky::Attachment::Extractor
  include Lucky::Attachment::Extractor::RunCommand

  # Extracts the MIME type using the `file` utility.
  def extract(uploaded_file, metadata, **options) : String?
    # NOTE: Avoids returning "application/x-empty" for empty files
    return nil if uploaded_file.size.try &.zero?

    run_command("file", %w[--mime-type --brief], uploaded_file.tempfile)
  end
end
