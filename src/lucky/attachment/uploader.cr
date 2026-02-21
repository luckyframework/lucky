require "uuid"

module Lucky::Attachment
  # Base uploader class that handles file uploads with metadata extraction and
  # location generation.
  #
  # ```
  # struct ImageUploader < Lucky::Attachment::Uploader
  #   def generate_location(io, metadata, **options) : String
  #     date = Time.utc.to_s("%Y/%m/%d")
  #     File.join("images", date, super)
  #   end
  # end
  #
  # ImageUploader.new("store").upload(io)
  # # => Lucky::Attachment::StoredFile with id "images/2024/01/15/abc123.jpg"
  # ```
  #
  abstract struct Uploader
    getter storage_key : String

    def initialize(@storage_key : String)
    end

    # Returns the storage instance for this uploader.
    def storage : Storage::Base
      Lucky::Attachment.find_storage(storage_key)
    end

    # Uploads a file and returns a `Lucky::Attachment::StoredFile`. This method
    # accepts additional metadata and arbitrary arguments for overrides.
    #
    # ```
    # uploader.upload(io)
    # uploader.upload(io, metadata: {"custom" => "value"})
    # uploader.upload(io, location: "custom/path.jpg")
    # ```
    #
    def upload(io : IO, metadata : MetadataHash? = nil, **options) : StoredFile
      data = extract_metadata(io, metadata, **options)
      data = data.merge(metadata) if metadata
      location = options[:location]? || generate_location(io, data, **options)

      storage.upload(io, location, **options.merge(metadata: data))
      StoredFile.new(id: location, storage_key: storage_key, metadata: data)
    ensure
      io.close if options[:close]?.nil? || options[:close]?
    end

    # Uploads to the "cache" storage.
    #
    # ```
    # cached = ImageUploader.cache(io)
    # ```
    def self.cache(io : IO, **options) : StoredFile
      new("cache").upload(io, **options)
    end

    # Uploads to the "store" storage.
    #
    # ```
    # stored = ImageUploader.store(io)
    # ```
    #
    def self.store(io : IO, **options) : StoredFile
      new("store").upload(io, **options)
    end

    # Promotes a file from cache to store.
    #
    # ```
    # cached = ImageUploader.cache(io)
    # stored = ImageUploader.promote(cached)
    # ```
    #
    def self.promote(
      file : StoredFile,
      to storage : String = "store",
      delete_source : Bool = true,
      **options,
    ) : StoredFile
      Lucky::Attachment.promote(
        file,
        **options,
        to: storage,
        delete_source: delete_source
      )
    end

    # Generates a unique location for the uploaded file. Override this in
    # subclasses for custom locations.
    #
    # ```
    # class ImageUploader < Lucky::Attachment::Uploader
    #   def generate_location(io, metadata, **options) : String
    #     File.join("images", super)
    #   end
    # end
    # ```
    #
    def generate_location(io : IO, metadata : MetadataHash, **options) : String
      extension = extract_extension(io, metadata)
      basename = generate_uid
      extension ? "#{basename}.#{extension}" : basename
    end

    # Extracts metadata from the IO. Override in subclasses to add custom
    # metadata extraction.
    #
    # ```
    # class ImageUploader < Lucky::Attachment::Uploader
    #   def extract_metadata(io, metadata : MetadataHash? = nil, **options) : MetadataHash
    #     data = super
    #     # Add custom metadata
    #     data["custom"] = "value"
    #     data
    #   end
    # end
    # ```
    #
    def extract_metadata(
      io : IO,
      metadata : MetadataHash? = nil,
      **options,
    ) : MetadataHash
      MetadataHash{
        "filename"  => options[:filename]? || extract_filename(io),
        "size"      => extract_size(io),
        "mime_type" => extract_mime_type(io),
      }
    end

    # Generates a unique identifier for file locations.
    protected def generate_uid : String
      UUID.random.to_s
    end

    # Extracts the filename from the IO if available.
    protected def extract_filename(io : IO) : String?
      if io.responds_to?(:original_filename)
        io.original_filename
      elsif io.responds_to?(:filename)
        io.filename.presence
      elsif io.responds_to?(:path)
        File.basename(io.path)
      end
    end

    # Extracts the file size from the IO, if available.
    protected def extract_size(io : IO) : Int64?
      if io.responds_to?(:tempfile)
        io.tempfile.size
      elsif io.responds_to?(:size)
        io.size.to_i64
      end
    end

    # Extracts the MIME type from the IO if available.
    #
    # NOTE: This relies on the IO providing content_type, which typically comes
    # from HTTP headers and may not be accurate, but it's a good fallback.
    #
    protected def extract_mime_type(io : IO) : String?
      return unless io.responds_to?(:content_type) && (type = io.content_type)

      type.split(';').first.strip
    end

    # Extracts file extension from the IO or metadata.
    protected def extract_extension(
      io : IO,
      metadata : MetadataHash,
    ) : String?
      if filename = metadata["filename"]?.try(&.as(String))
        ext = File.extname(filename).lchop('.')
        return ext.downcase unless ext.empty?
      end

      if io.responds_to?(:path)
        ext = File.extname(io.path).lchop('.')
        return ext.downcase unless ext.empty?
      end
    end
  end
end
