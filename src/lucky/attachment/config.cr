require "habitat"
require "./storage"

module Lucky::Attachment
  Habitat.create do
    # Storage configurations keyed by name. The default storages are typically:
    # - "cache" (temporary storage between requests to avoid re-uploads)
    # - "store" (where uploads are moved from the cache after a commit)
    #
    # NOTE: Additional stores are not supported yet. Please reach out if that
    # is something you need.
    #
    setting storages : Hash(String, Storage) = {} of String => Storage

    # Path prefix for uploads. Possible keywords are:
    # - `:model` (an underscored string of the model name)
    # - `:id` (the record's primary key value)
    # - `:attachment` (the name of the attachment; e.g. "avatar")
    #
    setting path_prefix : String = ":model/:id/:attachment"
  end

  # Retrieves a storage by name, raising if not found.
  #
  # ```
  # Lucky::Attachment.find_storage("store")   # => Storage::FileSystem
  # Lucky::Attachment.find_storage("missing") # raises Lucky::Attachment::Error
  # ```
  #
  def self.find_storage(name : String) : Storage
    settings.storages[name]? ||
      raise Error.new(
        String.build do |io|
          if settings.storages.keys.empty?
            io << "There are no storages registered yet"
          else
            io << %(Storage ) << name.inspect
            io << %( is not registered. The available storages are: )
            io << settings.storages.keys.map(&.inspect).join(", ")
          end
        end
      )
  end
end
