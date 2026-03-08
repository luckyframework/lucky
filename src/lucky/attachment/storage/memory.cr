require "../storage"

# In-memory storage backend for testing purposes. Files are stored in a hash
# and are lost when the process exits. This is useful for testing without
# hitting the filesystem or network.
#
# ```
# Lucky::Attachment.configure do |settings|
#   settings.storages["cache"] = Lucky::Attachment::Storage::Memory.new
#   settings.storages["store"] = Lucky::Attachment::Storage::Memory.new
# end
# ```
#
class Lucky::Attachment::Storage::Memory < Lucky::Attachment::Storage
  getter store : Hash(String, Bytes)
  getter base_url : String?

  def initialize(@base_url : String? = nil)
    @store = {} of String => Bytes
  end

  # Uploads an IO to the given location (id) in the storage.
  def upload(io : IO, id : String, **options) : Nil
    @store[id] = io.getb_to_end
  end

  # Opens the file at the given location and returns an IO for reading.
  def open(id : String, **options) : IO
    if bytes = @store[id]?
      IO::Memory.new(bytes)
    else
      raise FileNotFound.new("File not found: #{id}")
    end
  end

  # Returns whether a file exists at the given location.
  def exists?(id : String) : Bool
    @store.has_key?(id)
  end

  # Returns the URL for accessing the file at the given location.
  def url(id : String, **options) : String
    String.build do |io|
      if base = @base_url
        io << base.rstrip('/')
      end
      io << '/' << id
    end
  end

  # Deletes the file at the given location.
  def delete(id : String) : Nil
    @store.delete(id)
  end

  # Clears out the store.
  def clear! : Nil
    @store.clear
  end

  # Returns the number of stored files.
  def size : Int32
    @store.size
  end
end
