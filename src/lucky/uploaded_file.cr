require "tempfile"

class Lucky::UploadedFile
  getter name : String
  getter tempfile : Tempfile
  getter metadata : HTTP::FormData::FileMetadata

  def initialize(part : HTTP::FormData::Part)
    @name = part.name
    @tempfile = Tempfile.open(part.name) do |tempfile|
      IO.copy(part.body, tempfile)
    end
    @metadata =
      HTTP::FormData.parse_content_disposition(part.headers["Content-Disposition"]).last
  end

  def path
    @tempfile.path
  end
end
