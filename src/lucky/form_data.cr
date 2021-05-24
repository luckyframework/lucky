class Lucky::FormData
  getter params = MultiValueStorage(String).new
  getter files = MultiValueStorage(Lucky::UploadedFile).new

  def add(part : HTTP::FormData::Part)
    case part.headers
    when .includes_word?("Content-Disposition", "filename")
      files.add(part.name, Lucky::UploadedFile.new(part))
    else
      params.add(part.name, part.body.gets_to_end)
    end
  end

  # Simpler, generic implementation of HTTP::Params
  class MultiValueStorage(T)
    include Enumerable({String, T})

    private getter storage : Hash(String, Array(T))

    def initialize
      @storage = {} of String => Array(T)
    end

    def []?(key : String) : T?
      storage[key]?.try(&.first?)
    end

    def fetch_all(key : String) : Array(T)
      storage.fetch(key) { [] of T }
    end

    def add(key : String, value : T)
      storage[key] ||= [] of T
      storage[key] << value
    end

    def each
      storage.each do |name, values|
        values.each do |value|
          yield({name, value})
        end
      end
    end
  end
end
