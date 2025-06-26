# Registry for custom formats that extends the built-in Format enum
module Lucky::FormatRegistry
  # Storage for custom format mappings
  class_getter custom_formats = {} of String => CustomFormat

  # Represents a custom format that users can register
  struct CustomFormat
    getter name : String
    getter extension : String
    getter mime_type : String

    def initialize(@name : String, @extension : String, @mime_type : String)
    end

    def to_s(io : IO) : Nil
      io << name
    end
  end

  # Register a custom format
  def self.register(name : String, extension : String, mime_type : String) : Nil
    custom_formats[name] = CustomFormat.new(name, extension, mime_type)
  end

  # Find format by extension (checks both built-in and custom formats)
  def self.from_extension(extension : String) : Lucky::Format | CustomFormat | Nil
    # Try built-in formats first
    if format = Lucky::Format.from_extension(extension)
      return format
    end

    # Check custom formats
    custom_formats.each_value do |custom_format|
      return custom_format if custom_format.extension.downcase == extension.downcase
    end

    nil
  end

  # Find format by MIME type (checks both built-in and custom formats)
  def self.from_mime_type(mime_type : String) : Lucky::Format | CustomFormat | Nil
    # Try built-in formats first
    if format = Lucky::Format.from_mime_type(mime_type)
      return format
    end

    # Check custom formats
    custom_formats.each_value do |custom_format|
      return custom_format if custom_format.mime_type.downcase == mime_type.downcase
    end

    nil
  end

  # Get all known extensions (built-in + custom)
  def self.known_extensions : Array(String)
    built_in = Lucky::Format.values.map(&.to_extension).reject(&.empty?)
    custom = custom_formats.values.map(&.extension)
    (built_in + custom).uniq
  end

  # Get all known MIME types (built-in + custom)
  def self.known_mime_types : Array(String)
    built_in = Lucky::Format.values.map(&.to_mime_type)
    custom = custom_formats.values.map(&.mime_type)
    (built_in + custom).uniq
  end
end
