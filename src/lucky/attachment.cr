require "./attachment/storage"

module Lucky::Attachment
  alias MetadataValue = String | Int64 | Int32 | Float64 | Bool | Nil
  alias MetadataHash = Hash(String, MetadataValue)

  annotation MetadataMethods
  end

  class Error < Exception; end

  class FileNotFound < Error; end

  class InvalidFile < Error; end

  class CliToolNotFound < Error; end
end
