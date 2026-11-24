# This class represents an uploaded file from a form
class Lucky::UploadedFile
  private getter part : HTTP::FormData::Part

  getter filename : String

  @contents : Bytes
  @tempfile : File?

  delegate name, creation_time, modification_time, read_time, size, to: @part

  # Creates an UploadedFile using a HTTP::FormData::Part.
  #
  # The new file will be assigned the **name** of the
  # provided HTTP::FormData::Part and the **tempfile** will
  # be assigned the body of the HTTP::FormData::Part
  def initialize(@part : HTTP::FormData::Part)
    @filename = @part.filename.presence || Random.new.hex(12)
    @contents = @part.body.getb_to_end
  end

  def tempfile : File
    @tempfile ||= write_tempfile
  end

  # Returns the path of the File as a String
  #
  # ```
  # uploaded_file_object.path # => String
  # ```
  def path : String
    tempfile.path
  end

  # Tests if the file size is zero.
  #
  # ```
  # uploaded_file_object.blank? # => Bool
  # ```
  def blank? : Bool
    @contents.empty?
  end

  def delete : Nil
    if file = @tempfile
      file.close
      File.delete?(file.path)
      @tempfile = nil
    end
  end

  # Avram::Uploadable needs to be updated when this is removed
  @[Deprecated("`metadata` deprecated. Each method on metadata is accessible directly on Lucky::UploadedFile")]
  def metadata : HTTP::FormData::FileMetadata
    HTTP::FormData::FileMetadata.new(filename, creation_time, modification_time, read_time, size)
  end

  private def write_tempfile : File
    file = File.tempfile(filename.gsub(/[\/\\\0]/, "_"))

    begin
      file.write(@contents)
      file.rewind
    rescue ex
      file.close
      File.delete?(file.path)
      raise ex
    end

    file
  end
end
