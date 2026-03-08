require "uuid"

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
abstract struct Lucky::Attachment::Uploader
  EXTRACTORS = {
    "filename"  => Extractor::FilenameFromIO.new,
    "mime_type" => Extractor::MimeFromIO.new,
    "size"      => Extractor::SizeFromIO.new,
  } of String => Extractor

  # Registers an extractor for a given key.
  #
  # ```
  # struct PdfUploader < Lucky::Attachment::Uploader
  #   # Use a different MIME type extractor than the default one
  #   extract mime_type : Lucky::Attachment::Extractor::MimeFromExtension
  #
  #   # Or use your own custom extractor to add arbitrary data
  #   extract pages : MyNumberOfPagesExtractor
  # end
  # ```
  #
  # The result will then be added to the attachment's metadata after uploading:
  # ```
  # invoice.pdf.metadata["pages"]
  # # => 24
  # ```
  #
  macro extract(type_declaration)
    EXTRACTORS["{{type_declaration.var.id}}"] = {{type_declaration.type}}.new
  end

  getter storage_key : String

  def initialize(@storage_key : String)
  end

  # Returns the storage instance for this uploader.
  def storage : Storage
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
  end

  # Uploads to the "cache" storage.
  #
  # ```
  # cached = ImageUploader.cache(io)
  # ```
  #
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
    extension = file_extension(io, metadata)
    basename = generate_uid(io, metadata, **options)
    filename = extension ? "#{basename}.#{extension}" : basename
    File.join([options[:path_prefix]?, filename].compact)
  end

  # Generates a unique identifier for file locations. Override this in
  # subclasses for custom filenames in the storage.
  #
  # ```
  # class ImageUploader < Lucky::Attachment::Uploader
  #   def generate_uid(io, metadata, **options) : String
  #     "#{metadata["filename"]}-#{Time.local.to_unix}"
  #   end
  # end
  # ```
  #
  def generate_uid(io : IO, metadata : MetadataHash, **options) : String
    UUID.random.to_s
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
    (metadata.try(&.dup) || MetadataHash.new).tap do |data|
      EXTRACTORS.each do |key, extractor|
        if value = extractor.extract(io, data, **options)
          data[key] = value
        end
      end
    end
  end

  # Tries to determine the file extension from the metadata or IO.
  protected def file_extension(
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
