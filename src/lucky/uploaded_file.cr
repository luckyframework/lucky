# This class represents an uploaded file from a form
class Lucky::UploadedFile
  private getter part : HTTP::FormData::Part

  getter filename : String
  getter tempfile : File

  delegate name, creation_time, modification_time, read_time, size, to: @part

  # Creates an UploadedFile using a HTTP::FormData::Part.
  #
  # The new file will be assigned the **name** of the
  # provided HTTP::FormData::Part and the **tempfile** will
  # be assigned the body of the HTTP::FormData::Part
  def initialize(@part : HTTP::FormData::Part)
    @filename = @part.filename.presence || Random.new.hex(12)
    @tempfile = File.tempfile(filename)

    File.open(@tempfile.path, "w") do |tempfile|
      IO.copy(@part.body, tempfile)
    end
  end

  # Returns the path of the File as a String
  #
  # ```
  # uploaded_file_object.path # => String
  # ```
  def path : String
    @tempfile.path
  end

  # Tests if the file size is zero.
  #
  # ```
  # uploaded_file_object.blank? # => Bool
  # ```
  def blank? : Bool
    tempfile.size.zero?
  end
end
