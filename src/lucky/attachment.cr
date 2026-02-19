require "habitat"
require "./attachment/uploaded_file"
require "./attachment/storage"
require "./attachment/storage/memory"
require "./attachment/storage/file_system"
require "./attachment/uploader"

module Lucky::Attachment
  Log = ::Log.for("lucky.attachment")

  Habitat.create do
    # Storage configurations keyed by name ("cache", "store", etc.)
    setting storages : Hash(String, Storage::Base) = {} of String => Storage::Base
  end

  # Retrieves a storage by name, raising if not found.
  #
  # ```
  # Lucky::Attachment.find_storage("store")   # => Storage::FileSystem
  # Lucky::Attachment.find_storage("missing") # raises Lucky::Attachment::Error
  # ```
  def self.find_storage(name : String) : Storage::Base
    settings.storages[name]? ||
      raise Error.new(
        "Storage #{name.inspect} is not registered." \
        "Available storages: #{settings.storages.keys.inspect}"
      )
  end

  # Move a file from one storage to another (typically cache -> store).
  #
  # ```
  # stored = Lucky::Attachment.promote(cached, to: "store")
  # ```
  def self.promote(
    file : UploadedFile,
    to storage : String,
    delete_source : Bool = true,
  ) : UploadedFile
    file.open do |io|
      find_storage(storage).upload(io, file.id, metadata: file.metadata)
      promoted = UploadedFile.new(
        id: file.id,
        storage_key: storage,
        metadata: file.metadata
      )
      file.delete if delete_source
      promoted
    end
  end

  # Deserialize an UploadedFile from various sources.
  #
  # ```
  # Lucky::Attachment.uploaded_file(json_string)
  # Lucky::Attachment.uploaded_file(json_any)
  # Lucky::Attachment.uploaded_file(uploaded_file)
  # ```
  def self.uploaded_file(json : String) : UploadedFile
    UploadedFile.from_json(json)
  end

  def self.uploaded_file(json : JSON::Any) : UploadedFile
    UploadedFile.from_json(json.to_json)
  end

  def self.uploaded_file(file : UploadedFile) : UploadedFile
    file
  end

  def self.uploaded_file(value : Nil) : Nil
    nil
  end

  # Utility to work with a file IO. If the IO is already a File, yields it
  # directly, Otherwise copies to a tempfile, yields it, then cleans up.
  #
  # ```
  # Lucky::Attachment.with_file(io) do |file|
  #   # file is guaranteed to be a File with a path
  # end
  # ```
  def self.with_file(io : IO, &)
    if io.is_a?(File)
      yield io
    else
      File.tempfile("lucky-attachment") do |tempfile|
        IO.copy(io, tempfile)
        tempfile.rewind
        yield tempfile
      end
    end
  end

  def self.with_file(uploaded_file : UploadedFile, &)
    uploaded_file.download do |tempfile|
      yield tempfile
    end
  end

  class Error < Exception; end

  class FileNotFound < Error; end

  class InvalidFile < Error; end
end
