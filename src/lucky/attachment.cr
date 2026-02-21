require "./attachment/storage"

module Lucky::Attachment
  alias MetadataValue = String | Int32 | Int64 | UInt32 | UInt64 | Float64 | Bool | Nil
  alias MetadataHash = Hash(String, MetadataValue)

  # Log = ::Log.for("lucky.attachment")

  class Error < Exception; end

  class FileNotFound < Error; end

  class InvalidFile < Error; end
end
