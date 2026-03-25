require "./run_command"

@[Lucky::Attachment::MetadataMethods(width : Int32, height : Int32)]
struct Lucky::Attachment::Extractor::DimensionsFromMagick
  include Lucky::Attachment::Extractor
  include Lucky::Attachment::Extractor::RunCommand

  ARGS = ["identify", "-format", "%[fx:w] %[fx:h]"]

  # Extracts the dimensions of a file using ImageMagick's `magick` command.
  def extract(uploaded_file, metadata, **options) : Nil
    return unless result = run_magick_command(uploaded_file.tempfile)

    dimensions = result.split
    return unless dimensions.size >= 2

    metadata["width"] = dimensions[0].to_i
    metadata["height"] = dimensions[1].to_i
  end

  private def run_magick_command(io)
    run_command("magick", ARGS, io)
  rescue CliToolNotFound
    run_command("identify", ARGS[1..], io)
  end
end
