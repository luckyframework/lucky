require "habitat"
require "./storage"

module Lucky::Attachment
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
  #
  def self.find_storage(name : String) : Storage::Base
    settings.storages[name]? ||
      raise Error.new(
        String.build do |io|
          if settings.storages.keys.empty?
            io << "There are no storages registered yet"
          else
            io << %(Storage ) << name.inspect
            io << %( is not registered. The available storages are: )
            io << settings.storages.keys.map { |s| s.inspect }.join(", ")
          end
        end
      )
  end
end
