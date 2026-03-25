# Storage backends handle the actual persistence of uploaded files.
# Implementations must provide methods for uploading, retrieving, checking
# existence, and deleting files.
#
abstract class Lucky::Attachment::Storage
  # Uploads an IO to the given location (id) in the storage.
  #
  # ```
  # storage.upload(io, "uploads/photo.jpg")
  # storage.upload(io, "uploads/photo.jpg", metadata: {"filename" => "original.jpg"})
  # ```
  #
  abstract def upload(io : IO, id : String, **options) : Nil

  # Opens the file at the given location and returns an IO for reading.
  #
  # ```
  # io = storage.open("uploads/photo.jpg")
  # content = io.gets_to_end
  # io.close
  # ```
  #
  # Raises `Lucky::Attachment::FileNotFound` if the file doesn't exist.
  #
  abstract def open(id : String, **options) : IO

  # Returns whether a file exists at the given location.
  #
  # ```
  # storage.exists?("uploads/photo.jpg")
  # # => true
  # ```
  #
  abstract def exists?(id : String) : Bool

  # Returns the URL for accessing the file at the given location.
  #
  # ```
  # storage.url("uploads/photo.jpg")
  # # => "/uploads/photo.jpg"
  # storage.url("uploads/photo.jpg", host: "https://example.com")
  # # => "https://example.com/uploads/photo.jpg"
  # ```
  #
  abstract def url(id : String, **options) : String

  # Deletes the file at the given location.
  #
  # ```
  # storage.delete("uploads/photo.jpg")
  # ```
  #
  # Does not raise if the file doesn't exist.
  #
  abstract def delete(id : String) : Nil

  # Moves an IO from another location.
  def move(io : IO, id : String, **options) : Nil
    upload(io, id, **options)
  end

  # Moves a file from another location.
  def move(file : Lucky::Attachment::StoredFile, id : String, **options) : Nil
    upload(file.io, id, **options)
  end
end
