# This class represents an uploaded file from a form
class Lucky::UploadedFile
  private getter part : HTTP::FormData::Part
  getter tempfile : File

  delegate name, creation_time, modification_time, read_time, size, to: @part

  # Creates an UploadedFile using a HTTP::FormData::Part.
  #
  # The new file will be assigned the **name** of the
  # provided HTTP::FormData::Part and the **tempfile** will
  # be assigned the body of the HTTP::FormData::Part
  def initialize(@part : HTTP::FormData::Part)
    @tempfile = File.tempfile(@part.name)
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

  # Returns the original name of the file
  #
  # ```
  # uploaded_file_object.filename # => String
  # ```
  def filename : String
    part.filename.to_s
  end

  # Tests if the file name is blank, which typically means no file was selected
  # at the time the form was submitted.
  #
  # ```
  # uploaded_file_object.blank? # => Bool
  # ```
  def blank? : Bool
    filename.blank?
  end

  @[Deprecated("`metadata` deprecated. Each method on metadata is accessible directly on Lucky::UploadedFile")]
  def metadata : HTTP::FormData::FileMetadata
    HTTP::FormData::FileMetadata.new(filename, creation_time, modification_time, read_time, size)
  end
end
