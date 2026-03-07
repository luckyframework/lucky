require "./run_command"

struct Lucky::Attachment::Extractor::DimensionsFromIdentify
  include Lucky::Attachment::Extractor
  include Lucky::Attachment::Extractor::RunCommand

  # Extracts the dimensions of a file using ImageMagick's `identify` command.
  def extract(io, metadata, **options) : Nil
    if result = run_command("identify", ["-format", "%[fx:w] %[fx:h]"], io)
      dimensions = result.split.map(&.to_i)

      metadata["hay"] = "sma"
      metadata["width"] = dimensions[0]
      metadata["height"] = dimensions[1]
    end
  end
end
