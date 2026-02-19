require "../storage"

module Lucky::Attachment
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
  class Storage::Memory < Storage::Base
    getter store : Hash(String, Bytes)
    getter base_url : String?

    def initialize(@base_url : String? = nil)
      @store = {} of String => Bytes
    end

    def upload(io : IO, id : String, **options) : Nil
      @store[id] = io.getb_to_end
    end

    def open(id : String, **options) : IO
      if bytes = @store[id]?
        IO::Memory.new(bytes)
      else
        raise FileNotFound.new("File not found: #{id}")
      end
    end

    def exists?(id : String) : Bool
      @store.has_key?(id)
    end

    def url(id : String, **options) : String
      if base = @base_url
        "#{base.rstrip('/')}/#{id}"
      else
        "/#{id}"
      end
    end

    def delete(id : String) : Nil
      @store.delete(id)
    end

    def clear! : Nil
      @store.clear
    end

    # Returns the number of stored files.
    def size : Int32
      @store.size
    end
  end
end
