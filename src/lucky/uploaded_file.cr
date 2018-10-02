require "tempfile"

class Lucky::UploadedFile
  getter name : String
  getter tempfile : Tempfile
  getter metadata : HTTP::FormData::FileMetadata

  # Creates an UploadedFile using a HTTP::FormData::Part.
  # The new file will be assigned the **name** of the
  # provided HTTP::FormData::Part and the **tempfile** will
  # be assigned the body of the HTTP::FormData::Part
  def initialize(part : HTTP::FormData::Part)
    @name = part.name
    @tempfile = Tempfile.open(part.name) do |tempfile|
      IO.copy(part.body, tempfile)
    end
    @metadata =
      HTTP::FormData.parse_content_disposition(part.headers["Content-Disposition"]).last
  end

  # Returns the path of the tempfile as a String
  #
  #```
  #uploaded_file_object.path #=> String
  #``` 
  def path
    @tempfile.path
  end
end
