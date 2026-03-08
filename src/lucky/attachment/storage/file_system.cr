require "../storage"

# Local filesystem storage backend. Files are stored in a directory on the
# local filesystem. Supports an optional prefix for organizing files.
#
# ```
# Lucky::Attachment.configure do |settings|
#   settings.storages["cache"] = Lucky::Attachment::Storage::FileSystem.new(
#     directory: "uploads",
#     prefix: "cache"
#   )
#   settings.storages["store"] = Lucky::Attachment::Storage::FileSystem.new(
#     directory: "uploads"
#   )
# end
# ```
#
class Lucky::Attachment::Storage::FileSystem < Lucky::Attachment::Storage
  DEFAULT_PERMISSIONS           = File::Permissions.new(0o644)
  DEFAULT_DIRECTORY_PERMISSIONS = File::Permissions.new(0o755)

  getter directory : String
  getter prefix : String?
  getter? clean : Bool
  getter permissions : File::Permissions
  getter directory_permissions : File::Permissions

  def initialize(
    @directory : String,
    @prefix : String? = nil,
    @clean : Bool = true,
    @permissions : File::Permissions = DEFAULT_PERMISSIONS,
    @directory_permissions : File::Permissions = DEFAULT_DIRECTORY_PERMISSIONS,
  )
    Dir.mkdir_p(expanded_directory, mode: directory_permissions.value)
  end

  # Returns the full expanded path including prefix.
  #
  # ```
  # storage.expanded_directory
  # # => "/app/uploads/cache"
  # ```
  #
  def expanded_directory : String
    return File.expand_path(directory) unless p = prefix

    File.expand_path(File.join(directory, p))
  end

  # Uploads an IO to the given location (id) in the storage.
  def upload(io : IO, id : String, move : Bool = false, **options) : Nil
    path = path_for(id)
    Dir.mkdir_p(File.dirname(path), mode: directory_permissions.value)

    if move && io.is_a?(File)
      File.rename(io.path, path)
      File.chmod(path, permissions)
    else
      File.open(path, "wb", perm: permissions) do |file|
        IO.copy(io, file)
      end
    end
  end

  # Opens the file at the given location and returns an IO for reading.
  def open(id : String, **options) : IO
    File.open(path_for(id), "rb")
  rescue ex : File::NotFoundError
    raise FileNotFound.new("File not found: #{id}")
  end

  # Returns whether a file exists at the given location.
  def exists?(id : String) : Bool
    File.exists?(path_for(id))
  end

  # Returns the full filesystem path for the given id.
  #
  # ```
  # storage.path_for("abc123.jpg")
  # # => "/app/uploads/abc123.jpg"
  # ```
  #
  def path_for(id : String) : String
    File.join(expanded_directory, id.gsub('/', File::SEPARATOR))
  end

  def url(id : String, host : String? = nil, **options) : String
    String.build do |url|
      url << host.rstrip('/') if host
      url << '/'
      if p = prefix
        url << p.lstrip('/') << '/'
      end
      url << id
    end
  end

  # Deletes the file at the given location.
  def delete(id : String) : Nil
    path = path_for(id)
    File.delete?(path)
    clean_directories(path) if clean?
  rescue ex : File::Error
    # Ignore errors here
  end

  # Override move for efficient file system rename
  def move(io : IO, id : String, **options) : Nil
    upload(io, id, **options, move: io.is_a?(File))
  end

  # Cleans empty parent directories up to the expanded_directory.
  private def clean_directories(path : String) : Nil
    current = File.dirname(path)

    while current != expanded_directory && current.starts_with?(expanded_directory)
      break unless Dir.empty?(current)
      Dir.delete(current)
      current = File.dirname(current)
    end
  rescue ex : File::Error
    # Ignore errors here
  end
end
