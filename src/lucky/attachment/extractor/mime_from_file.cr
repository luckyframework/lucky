require "./run_command"

struct Lucky::Attachment::Extractor::MimeFromFile
  include Lucky::Attachment::Extractor
  include Lucky::Attachment::Extractor::RunCommand

  # Extracts the MIME type using the `file` utility.
  def extract(io, metadata, **options) : String?
    # Avoids returning "application/x-empty" for empty files
    return nil if io.size.try &.zero?

    run_command("file", %w[--mime-type --brief], io)
  end
end
