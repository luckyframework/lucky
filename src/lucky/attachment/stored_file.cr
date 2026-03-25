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
abstract class Lucky::Attachment::StoredFile
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

  # Returns the file extension based on the id or original filename.
  #
  # NOTE: This method relies on `filename?` and `filename` which are generated
  # by the `extract` macro on `Lucky::Attachment::Uploader`. Concrete
  # `StoredFile` subclasses created through the `Uploader.inherited` macro
  # will have these methods available automatically.
  #
  # ```
  # file.extension?
  # # => "jpg"
  # ```
  #
  def extension? : String?
    ext = File.extname(id).lchop('.')
    ext = File.extname(filename).lchop('.') if ext.empty? && filename?
    ext.presence.try(&.downcase)
  end

  # The non-nilable variant of the `extension?` method.
  def extension : String
    extension?.as(String)
  end

  # Aliases the `[]?` method on the metadata property.
  #
  # ```
  # file["width"]?
  # # => 800
  # file["custom"]?
  # # => "value"
  # ```
  #
  def []?(key : String) : MetadataValue
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
    suffix = extension?.try { |ext| ".#{ext}" }
    tempfile = File.tempfile("lucky-attachment", suffix)
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

  # Compares two `StoredFile` by their id and storage.
  def ==(other : StoredFile) : Bool
    id == other.id && storage_key == other.storage_key
  end

  def ==(other) : Bool
    false
  end
end
