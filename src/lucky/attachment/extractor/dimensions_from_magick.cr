require "./run_command"

@[Lucky::Attachment::MetadataMethods(width : Int32, height : Int32)]
struct Lucky::Attachment::Extractor::DimensionsFromMagick
  include Lucky::Attachment::Extractor
  include Lucky::Attachment::Extractor::RunCommand

  # Extracts the dimensions of a file using ImageMagick's `magick` command.
  def extract(io, metadata, **options) : Nil
    if result = run_magick_command(io, ["identify", "-format", "%[fx:w] %[fx:h]"])
      dimensions = result.split.map(&.to_i)

      metadata["width"] = dimensions[0]
      metadata["height"] = dimensions[1]
    end
  end

  private def run_magick_command(io, args)
    run_command("magick", args, io)
  rescue CliToolNotFound
    run_command("identify", args[1..], io)
  end
end
