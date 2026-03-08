module Lucky::Attachment
  # Move a file from one storage to another (typically cache -> store).
  #
  # ```
  # stored = Lucky::Attachment.promote(cached, to: "store")
  # ```
  #
  def self.promote(
    file : StoredFile,
    to storage : String = "store",
    delete_source : Bool = true,
  ) : StoredFile
    file.open do |io|
      find_storage(storage).upload(io, file.id, metadata: file.metadata)
      promoted = StoredFile.new(
        id: file.id,
        storage_key: storage,
        metadata: file.metadata
      )
      file.delete if delete_source
      promoted
    end
  end

  # Deserialize an StoredFile from various sources.
  #
  # ```
  # Lucky::Attachment.uploaded_file(json_string)
  # Lucky::Attachment.uploaded_file(json_any)
  # Lucky::Attachment.uploaded_file(uploaded_file)
  # ```
  #
  def self.uploaded_file(json : String) : StoredFile
    StoredFile.from_json(json)
  end

  def self.uploaded_file(json : JSON::Any) : StoredFile
    StoredFile.from_json(json.to_json)
  end

  def self.uploaded_file(file : StoredFile) : StoredFile
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
  #
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

  def self.with_file(uploaded_file : StoredFile, &)
    uploaded_file.download do |tempfile|
      yield tempfile
    end
  end
end
