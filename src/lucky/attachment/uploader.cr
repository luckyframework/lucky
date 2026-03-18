require "uuid"

# Base uploader class that handles file uploads with metadata extraction and
# location generation.
#
# ```
# struct ImageUploader < Lucky::Attachment::Uploader
#   def generate_location(uploaded_file, metadata, **options) : String
#     date = Time.utc.to_s("%Y/%m/%d")
#     File.join("images", date, super)
#   end
# end
#
# ImageUploader.new("store").upload(uploaded_file)
# # => Lucky::Attachment::StoredFile with id "images/2024/01/15/abc123.jpg"
# ```
#
abstract struct Lucky::Attachment::Uploader
  alias MetadataHash = ::Lucky::Attachment::MetadataHash

  # Defines the path prefix for uploads in the storage. Overwrite this method
  # in uploader subclasses to use custom path prefixes per uploader.
  def self.path_prefix : String
    Lucky::Attachment.settings.path_prefix
  end

  # Defines the storages used by this uploader. Overwrite this method in
  # uploader subclasses to use different storages per uploader.
  def self.storages : NamedTuple(cache: String, store: String)
    {cache: "cache", store: "store"}
  end

  # Adds shorter local aliases for built-in extractors.
  # e.g. `Lucky::Attachment::Extractor::SizeFromIO` -> `SizeFromIOExtractor`
  {% for extractor in %w[
                        DimensionsFromMagick
                        FilenameFromIO
                        MimeFromExtension
                        MimeFromFile
                        MimeFromIO
                        SizeFromIO
                      ] %}
    alias {{ extractor.id }}Extractor = Lucky::Attachment::Extractor::{{ extractor.id }}
  {% end %}

  macro inherited
    {% stored_file = "#{@type}::StoredFile".id %}

    @@extractors = {} of String => Lucky::Attachment::Extractor

    class {{ stored_file }} < Lucky::Attachment::StoredFile
    end

    # Register default extractors
    extract filename, using: Lucky::Attachment::Extractor::FilenameFromIO
    extract mime_type, using: Lucky::Attachment::Extractor::MimeFromIO
    extract size, using: Lucky::Attachment::Extractor::SizeFromIO

    # Uploads a file and returns a `Lucky::Attachment::StoredFile`. This method
    # accepts additional metadata and arbitrary arguments for overrides.
    #
    # ```
    # uploader.upload(uploaded_file)
    # uploader.upload(uploaded_file, metadata: {"custom" => "value"})
    # uploader.upload(uploaded_file, location: "custom/path.jpg")
    # ```
    #
    def upload(
      uploaded_file : Lucky::UploadedFile,
      metadata : MetadataHash? = nil,
      **options
    ) : {{ stored_file }}
      data = extract_metadata(uploaded_file, metadata, **options)
      data = data.merge(metadata) if metadata
      location = options[:location]? || generate_location(uploaded_file, data, **options)

      storage.upload(uploaded_file.tempfile, location, **options.merge(metadata: data))
      {{ stored_file }}.new(id: location, storage_key: storage_key, metadata: data)
    end

    # Uploads to the "cache" storage.
    #
    # ```
    # cached = ImageUploader.cache(uploaded_file)
    # ```
    #
    def self.cache(
      uploaded_file : Lucky::UploadedFile,
      **options
    ) : {{ stored_file }}
      new(self.storages[:cache]).upload(uploaded_file, **options)
    end

    # Uploads to the "store" storage.
    #
    # ```
    # stored = ImageUploader.store(uploaded_file)
    # ```
    #
    def self.store(
      uploaded_file : Lucky::UploadedFile,
      **options
    ) : {{ stored_file }}
      new(self.storages[:store]).upload(uploaded_file, **options)
    end

    # Promotes a file from cache to store.
    #
    # ```
    # cached = ImageUploader.cache(uploaded_file)
    # stored = ImageUploader.promote(cached)
    # ```
    #
    def self.promote(
      stored_file : {{ stored_file }},
      to storage : String = self.storages[:store],
      delete_source : Bool = true,
      **options,
    ) : {{ stored_file }}
      store_location = options[:location]? || stored_file.id
      store_storage = ::Lucky::Attachment.find_storage(storage)
      store_storage.move(
        stored_file,
        store_location,
        **options,
        metadata: stored_file.metadata
      )
      promoted = {{ stored_file }}.new(
        id: store_location,
        storage_key: storage,
        metadata: stored_file.metadata
      )
      stored_file.delete if delete_source
      promoted
    end
  end

  # Registers an extractor for a given key.
  #
  # ```
  # struct PdfUploader < Lucky::Attachment::Uploader
  #   # Use a different MIME type extractor than the default one
  #   extract mime_type, using: Lucky::Attachment::Extractor::MimeFromExtension
  #
  #   # Or use your own custom extractor to add arbitrary data
  #   extract pages, using: MyNumberOfPagesExtractor
  # end
  # ```
  #
  # The result will then be added to the attachment's metadata after uploading:
  # ```
  # invoice.pdf.pages
  # # => 24
  # ```
  #
  macro extract(name, using)
    {%
      type = using.resolve.methods
        .find { |method| method.name == :extract.id }
        .return_type.types.first
    %}

    class {{ @type }}::StoredFile < Lucky::Attachment::StoredFile
      def {{ name }}? : {{ type }}?
        {% if {Int32, Int64}.includes? type.resolve %}
          if value = metadata["{{ name }}"]?
            {{ type }}.new(value.as(Int32 | Int64))
          end
        {% else %}
          metadata["{{ name }}"]?.try(&.as?({{ type }}))
        {% end %}
      end

      def {{ name }} : {{ type }}
        {% if {Int32, Int64}.includes? type.resolve %}
          {{ type }}.new(metadata["{{ name }}"].as(Int32 | Int64))
        {% else %}
          metadata["{{ name }}"].as({{ type }})
        {% end %}
      end

      {% if methods = using.resolve.annotation(Lucky::Attachment::MetadataMethods) %}
        {% for td in methods.args %}
          def {{ td.var }}? : {{ td.type }}?
            {% if {Int32, Int64}.includes? td.type.resolve %}
              if value = metadata["{{ td.var }}"]?
                {{ td.type }}.new(value.as(Int32 | Int64))
              end
            {% else %}
              metadata["{{ td.var }}"]?.try(&.as?({{ td.type }}))
            {% end %}
          end

          def {{ td.var }} : {{ td.type }}
            {% if {Int32, Int64}.includes? td.type.resolve %}
              {{ td.type }}.new(metadata["{{ td.var }}"].as(Int32 | Int64))
            {% else %}
              metadata["{{ td.var }}"].as({{ td.type }})
            {% end %}
          end
        {% end %}
      {% end %}
    end

    @@extractors["{{ name }}"] = {{ using }}.new
  end

  getter storage_key : String

  def initialize(@storage_key : String)
  end

  # Returns the storage instance for this uploader.
  def storage : Storage
    Lucky::Attachment.find_storage(storage_key)
  end

  # Generates a unique location for the uploaded file. Override this in
  # subclasses for custom locations.
  #
  # ```
  # class ImageUploader < Lucky::Attachment::Uploader
  #   def generate_location(uploaded_file, metadata, **options) : String
  #     File.join("images", super)
  #   end
  # end
  # ```
  #
  def generate_location(
    uploaded_file : Lucky::UploadedFile,
    metadata : MetadataHash,
    **options,
  ) : String
    extension = file_extension(uploaded_file, metadata)
    basename = generate_uid(uploaded_file, metadata, **options)
    filename = extension ? "#{basename}.#{extension}" : basename
    File.join([options[:path_prefix]?, filename].compact)
  end

  # Generates a unique identifier for file locations. Override this in
  # subclasses for custom filenames in the storage.
  #
  # ```
  # class ImageUploader < Lucky::Attachment::Uploader
  #   def generate_uid(uploaded_file, metadata, **options) : String
  #     "#{metadata["filename"]}-#{Time.local.to_unix}"
  #   end
  # end
  # ```
  #
  def generate_uid(
    uploaded_file : Lucky::UploadedFile,
    metadata : MetadataHash,
    **options,
  ) : String
    UUID.random.to_s
  end

  # Extracts metadata from the IO. Override in subclasses to add completely
  # custom metadata extraction outside of the `extract` DSL.
  #
  # ```
  # class ImageUploader < Lucky::Attachment::Uploader
  #   def extract_metadata(
  #     uploaded_file : Lucky::UploadedFile,
  #     metadata : MetadataHash? = nil,
  #     **options,
  #   ) : MetadataHash
  #     data = super
  #     # Add custom metadata
  #     data["custom"] = "value"
  #     data
  #   end
  #
  #   # Reopen the `StoredFile` class to add a method for the custom value.
  #   class StoredFile
  #     def custom : String
  #       metadata["custom"].as(String)
  #     end
  #   end
  # end
  # ```
  #
  def extract_metadata(
    uploaded_file : Lucky::UploadedFile,
    metadata : MetadataHash? = nil,
    **options,
  ) : MetadataHash
    (metadata.try(&.dup) || MetadataHash.new).tap do |data|
      @@extractors.each do |name, extractor|
        if value = extractor.extract(uploaded_file, data, **options)
          data[name] = value
        end
      end
    end
  end

  # Tries to determine the file extension from the metadata or IO.
  protected def file_extension(
    uploaded_file : Lucky::UploadedFile,
    metadata : MetadataHash,
  ) : String?
    if filename = metadata["filename"]?.try(&.as(String))
      ext = File.extname(filename).lchop('.')
      return ext.downcase unless ext.empty?
    end

    File.extname(uploaded_file.path).lchop('.').try(&.downcase.presence)
  end
end
