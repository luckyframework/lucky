require "json"
require "uuid"

# Represents a file that has been uploaded to a storage backend.
#
# This class is JSON serializable and stores the file's location (`id`),
# which storage it's in (`storage`), and associated metadata.
#
# NOTE: The JSON format is compatible with Shrine.rb/Shrine.cr:
#
# ```json
# {
#   "id": "uploads/abc123.jpg",
#   "storage": "store",
#   "metadata": {
#     "filename": "photo.jpg",
#     "size": 102400,
#     "mime_type": "image/jpeg"
#   }
# }
# ```
#
class Lucky::Attachment::StoredFile
  include JSON::Serializable

  # NOTE: This mimics the behavior of Avram's `JSON::Serializable` extension.
  def self.adapter
    Lucky(self)
  end

  getter id : String
  @[JSON::Field(key: "storage")]
  getter storage_key : String
  getter metadata : MetadataHash

  @[JSON::Field(ignore: true)]
  @io : IO?

  def initialize(
    @id : String,
    @storage_key : String,
    @metadata : MetadataHash = MetadataHash.new,
  )
  end

  # Returns the original filename from metadata.
  #
  # ```
  # file.original_filename
  # # => "photo.jpg"
  # ```
  #
  def original_filename : String?
    metadata["filename"]?.try(&.as(String))
  end

  # Returns the file extension based on the id or original filename.
  #
  # ```
  # file.extension
  # # => "jpg"
  # ```
  #
  def extension : String?
    ext = File.extname(id).lchop('.')
    if ext.empty? && original_filename
      ext = File.extname(original_filename.to_s).lchop('.')
    end
    ext.presence.try(&.downcase)
  end

  # Returns the file size in bytes from metadata.
  #
  # ```
  # file.size
  # # => 102400
  # ```
  #
  def size : Int64?
    case value = metadata["size"]?
    when Int32  then value.to_i64
    when Int64  then value
    when String then value.to_i64?
    else             nil
    end
  end

  # Returns the MIME type from metadata.
  #
  # ```
  # file.mime_type
  # # => "image/jpeg"
  # ```
  #
  def mime_type : String?
    metadata["mime_type"]?.try(&.as(String))
  end

  # Access arbitrary metadata values.
  #
  # ```
  # file["width"]
  # # => 800
  # file["custom"]
  # # => "value"
  # ```
  #
  def [](key : String) : MetadataValue
    metadata[key]?
  end

  # Returns the storage instance this file is stored in.
  def storage : Storage
    ::Lucky::Attachment.find_storage(storage_key)
  end

  # Returns the URL for accessing this file.
  #
  # ```
  # file.url
  # # => "https://bucket.s3.amazonaws.com/uploads/abc123.jpg"
  #
  # # for presigned URLs
  # file.url(expires_in: 1.hour)
  # ```
  #
  def url(**options) : String
    storage.url(id, **options)
  end

  # Returns whether this file exists in storage.
  #
  # ```
  # file.exists? # => true
  # ```
  #
  def exists? : Bool
    storage.exists?(id)
  end

  # Opens the file for reading. If a block is given, yields the IO and
  # automatically closes it afterwards. Returns the block's return value.
  #
  # ```
  # file.open do |io|
  #   io.gets_to_end
  # end
  # ```
  #
  def open(**options, &)
    io = storage.open(id, **options)
    begin
      yield io
    ensure
      io.close
    end
  end

  # Opens the file and stores the IO handle internally for subsequent reads.
  # Remember to call `close` when done.
  #
  # ```
  # file.open
  # content = file.io.gets_to_end
  # file.close
  # ```
  def open(**options) : IO
    close if @io
    @io = storage.open(id, **options)
  end

  # Returns the currently opened IO, or opens it if not already open.
  def io : IO
    @io || open
  end

  # Closes the file if it is open.
  def close : Nil
    @io.try(&.close)
    @io = nil
  end

  # Tests whether the file has been opened or not.
  def opened? : Bool
    !@io.nil?
  end

  # Downloads the file to a temporary file and returns it. As opposed to the
  # block variant, this temporary file needs to be closed and deleted
  # manually:
  #
  # ```
  # tempfile = file.download
  # tempfile.path
  # # => "/tmp/lucky-attachment123456789.jpg"
  # tempfile.gets_to_end
  # # => "file content"
  # tempfile.close
  # tempfile.delete
  # ```
  #
  def download(**options) : File
    tempfile = File.tempfile("lucky-attachment", ".#{extension}")
    stream(tempfile, **options)
    tempfile.rewind
    tempfile
  end

  # Downloads to a tempfile, yields it to the block, then cleans up.
  #
  # ```
  # file.download do |tempfile|
  #   process(tempfile.path)
  # end
  # # tempfile is automatically deleted
  # ```
  #
  def download(**options, &)
    tempfile = download(**options)
    begin
      yield tempfile
    ensure
      tempfile.close
      tempfile.delete
    end
  end

  # Streams the file content to the given IO destination.
  #
  # ```
  # file.stream(response.output)
  # ```
  #
  def stream(destination : IO, **options) : Nil
    if opened?
      IO.copy(io, destination)
      io.rewind if io.responds_to?(:rewind)
    else
      open(**options) do |io|
        IO.copy(io, destination)
      end
    end
  end

  # Deletes the file from storage.
  #
  # ```
  # file.delete
  # ```
  #
  def delete : Nil
    storage.delete(id)
  end

  # Returns a hash representation suitable for JSON serialization compatible
  # with Shrine.
  def data : Hash(String, String | MetadataHash)
    {
      "id"       => id,
      "metadata" => metadata,
      "storage"  => storage_key,
    }
  end

  # Compares two `StoredFile` by thier id and storage.
  def ==(other : StoredFile) : Bool
    id == other.id && storage_key == other.storage_key
  end

  def ==(other) : Bool
    false
  end
end
