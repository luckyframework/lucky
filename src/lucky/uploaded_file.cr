# This class represents an uploaded file from a form
class Lucky::UploadedFile
  include Avram::Uploadable

  getter name : String
  getter tempfile : File
  getter metadata : HTTP::FormData::FileMetadata

  # Creates an UploadedFile using a HTTP::FormData::Part.
  #
  # The new file will be assigned the **name** of the
  # provided HTTP::FormData::Part and the **tempfile** will
  # be assigned the body of the HTTP::FormData::Part
  def initialize(part : HTTP::FormData::Part)
    @name = part.name
    @tempfile = File.tempfile(part.name)
    File.open(@tempfile.path, "w") do |tempfile|
      IO.copy(part.body, tempfile)
    end
    @metadata =
      HTTP::FormData.parse_content_disposition(part.headers["Content-Disposition"]).last
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
    metadata.filename.to_s
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
end
