require "../storage"
require "awscr-s3"

# S3-compatible storage backend. Supports AWS S3 and any S3-compatible service
# such as RustFS, Tigris, or Cloudflare R2 via a custom endpoint.
#
# Requires the `awscr-s3` shard to be added to your `shard.yml`:
#
# ```yaml
# dependencies:
#   awscr-s3:
#     github: taylorfinnell/awscr-s3
# ```
#
# ## AWS S3
#
# ```
# Lucky::Attachment::Storage::S3.new(
#   bucket: "lucky-bucket",
#   region: "eu-west-1",
#   access_key_id: ENV["KEY"],
#   secret_access_key: ENV["SECRET"]
# )
# ```
#
# ## RustFS or other S3-compatible services
#
# ```
# Lucky::Attachment::Storage::S3.new(
#   bucket: "lucky-bucket",
#   region: "eu-west-1",
#   access_key_id: ENV["KEY"],
#   secret_access_key: ENV["SECRET"],
#   endpoint: "http://localhost:9000"
# )
# ```
#
# ## Bring your own client
#
# ```
# client = Awscr::S3::Client.new("eu-west-1", ENV["KEY"], ENV["SECRET"])
# Lucky::Attachment::Storage::S3.new(bucket: "lucky-bucket", client: client)
# ```
#
class Lucky::Attachment::Storage::S3 < Lucky::Attachment::Storage
  getter bucket : String
  getter prefix : String?
  getter? public : Bool
  getter upload_options : Hash(String, String)
  getter client : Awscr::S3::Client

  # Initialises a storage using credentials.
  #
  # ```
  # storage = Lucky::Attachment::Storage::S3.new(
  #   bucket: "lucky-bucket",
  #   region: "eu-west-1",
  #   access_key_id: "key",
  #   secret_access_key: "secret",
  #   endpoint: "http://localhost:9000"
  # )
  # ```
  #
  def initialize(
    @bucket : String,
    region : String,
    @access_key_id : String,
    @secret_access_key : String,
    @prefix : String? = nil,
    endpoint : String? = nil,
    @public : Bool = false,
    @upload_options : Hash(String, String) = Hash(String, String).new,
  )
    @client = Awscr::S3::Client.new(
      region,
      @access_key_id,
      @secret_access_key,
      endpoint: endpoint
    )
  end

  # Initialises a storage with a pre-built `Awscr::S3::Client`. Useful when you
  # need full control over the client configuration, or in tests for example.
  #
  # ```
  # client = Awscr::S3::Client.new("eu-west-1", "key", "secret")
  # storage = Lucky::Attachment::Storage::S3.new(
  #   bucket: "lucky-bucket",
  #   client: client
  # )
  # ```
  #
  def initialize(
    @bucket : String,
    @client : Awscr::S3::Client,
    @prefix : String? = nil,
    @public : Bool = false,
    @upload_options : Hash(String, String) = Hash(String, String).new,
  )
    # NOTE: These attributes are protected on the client, so this is the only
    # way to get them.
    @access_key_id = @client.@aws_access_key
    @secret_access_key = @client.@aws_secret_key
  end

  # Uploads a File to the given key in the bucket using `FileUploader`, which
  # automatically switches to multipart uploads for files larger than 5MB.
  #
  # ```
  # storage.upload(File.open("photo.jpg"), "uploads/photo.jpg")
  # ```
  #
  def upload(file : File, id : String, **options) : Nil
    opts = Awscr::S3::FileUploader::Options.new(with_content_types: false)
    uploader = Awscr::S3::FileUploader.new(@client, opts)
    uploader.upload(
      bucket,
      object_key(id),
      file,
      build_upload_headers(**options)
    )
  end

  # Uploads an IO to the given key in the bucket. The IO is fully read into
  # memory before uploading because `awscr-s3` requires a sized body.
  #
  # NOTE: Prefer the `File` overload when possible to avoid reading the
  # entire file into memory and to benefit from automatic multipart uploads.
  #
  # ```
  # storage.upload(io, "uploads/photo.jpg")
  # storage.upload(io, "uploads/photo.jpg", metadata: {
  #   "filename"  => "photo.jpg",
  #   "mime_type" => "image/jpeg",
  # })
  # ```
  #
  def upload(io : IO, id : String, **options) : Nil
    @client.put_object(
      bucket,
      object_key(id),
      io.getb_to_end,
      build_upload_headers(**options)
    )
  end

  # Opens the S3 object and returns an `IO::Memory` for reading.
  #
  # ```
  # io = storage.open("uploads/photo.jpg")
  # content = io.gets_to_end
  # io.close
  # ```
  #
  # Raises `Lucky::Attachment::FileNotFound` if the object does not exist.
  #
  def open(id : String, **options) : IO
    buffer = IO::Memory.new
    @client.get_object(bucket, object_key(id)) do |response|
      IO.copy(response.body_io, buffer)
    end
    buffer.rewind
    buffer
  rescue ex : Awscr::S3::NoSuchKey
    raise FileNotFound.new("File not found: #{id}")
  end

  # Tests if an object exists in the bucket.
  #
  # ```
  # storage.exists?("uploads/photo.jpg")
  # # => true
  # ```
  #
  def exists?(id : String) : Bool
    @client.head_object(bucket, object: object_key(id))
    true
  rescue Awscr::S3::Exception
    false
  end

  # Returns the URL for accessing the object. When `expires_in` is provided
  # (in seconds), a presigned URL is returned. Otherwise a plain public URL is
  # constructed without any HTTP round-trip.
  #
  # ```
  # storage.url("uploads/photo.jpg")
  # # => "https://s3-eu-west-1.amazonaws.com/lucky-bucket/uploads/photo.jpg"
  #
  # storage.url("uploads/photo.jpg", expires_in: 3600)
  # # => "https://s3-eu-west-1.amazonaws.com/lucky-bucket/uploads/photo.jpg?X-Amz-Signature=..."
  # ```
  #
  def url(id : String, **options) : String
    return public_url(id) unless expires_in = options[:expires_in]?

    presigned_url(id, expires_in: expires_in.to_i)
  end

  # Deletes the object for the given key. Does not raise if the object does not
  # exist.
  #
  # ```
  # storage.delete("uploads/photo.jpg")
  # ```
  #
  def delete(id : String) : Nil
    @client.delete_object(bucket, object_key(id))
  end

  # Promotes a file efficiently using a server-side S3 copy when the source is
  # a `StoredFile` in the same bucket, avoiding the download/re-upload. Falls
  # back to a regular upload for plain `IO` sources.
  #
  def move(file : Lucky::Attachment::StoredFile, id : String, **options) : Nil
    return move(file.io, id, **options) unless same_bucket?(file)

    source_storage = file.storage.as(S3)
    copy_object(
      **options,
      source_key: source_storage.object_key(file.id),
      dest_key: object_key(id)
    )
  end

  # Returns the full object key including any configured prefix.
  #
  # ```
  # storage.object_key("photo.jpg")
  # # => "photo.jpg"
  # ```
  #
  def object_key(id : String) : String
    return id unless p = prefix

    "#{p.strip('/')}/#{id.lstrip('/')}"
  end

  # Builds a header hash for S3 upload requests. Headers are applied in order
  # of precedence: metadata defaults, then per-call overrides, then the ACL
  # flag, and finally `upload_options` fill in any remaining gaps.
  private def build_upload_headers(**options) : Hash(String, String)
    Hash(String, String).new.tap do |headers|
      apply_metadata_headers(headers, **options)
      apply_option_overrides(headers, **options)
      headers["x-amz-acl"] = "public-read" if public?
      apply_upload_options(headers)
    end
  end

  # Sets Content-Disposition and Content-Type from the metadata hash.
  private def apply_metadata_headers(
    headers : Hash(String, String),
    **options,
  ) : Nil
    return unless metadata = options[:metadata]?.try(&.as?(MetadataHash))

    if filename = metadata["filename"]?.try(&.as?(String))
      headers["Content-Disposition"] = %(inline; filename="#{filename}")
    end
    if mime_type = metadata["mime_type"]?.try(&.as?(String))
      headers["Content-Type"] = mime_type
    end
  end

  # Applies per-call `content_type` and `content_disposition` overrides.
  private def apply_option_overrides(
    headers : Hash(String, String),
    **options,
  ) : Nil
    if content_type = options[:content_type]?.try(&.to_s.presence)
      headers["Content-Type"] = content_type
    end
    if content_disposition = options[:content_disposition]?.try(&.to_s.presence)
      headers["Content-Disposition"] = content_disposition
    end
  end

  # Merges `upload_options` into the headers without overriding existing keys.
  private def apply_upload_options(headers : Hash(String, String)) : Nil
    @upload_options.each do |key, value|
      headers[key] ||= value
    end
  end

  # Builds a public url considering custom endpoints configured in the client.
  private def public_url(id : String) : String
    String.build do |io|
      if uri = endpoint_uri
        scheme = uri.scheme || "https"
        host = endpoint_host_with_port(uri)
      else
        scheme = "https"
        host = "s3-#{@client.region}.amazonaws.com"
      end
      io << scheme << "://" << host << '/' << bucket << '/' << object_key(id)
    end
  end

  # Builds a presigned url.
  private def presigned_url(id : String, expires_in : Int32) : String
    options = Awscr::S3::Presigned::Url::Options.new(
      aws_access_key: @access_key_id,
      aws_secret_key: @secret_access_key,
      region: @client.region,
      object: "/#{object_key(id)}",
      bucket: bucket,
      host_name: presigned_url_host_name,
      expires: expires_in,
    )
    Awscr::S3::Presigned::Url.new(options).for(:get)
  end

  # Builds the host name for the current endpoint.
  private def presigned_url_host_name : String?
    return unless uri = endpoint_uri

    endpoint_host_with_port(uri)
  rescue URI::Error
    raw_endpoint
  end

  # Copies an object to a new location.
  private def copy_object(source_key : String, dest_key : String, **options) : Nil
    @client.copy_object(
      bucket,
      source_key,
      dest_key,
      build_upload_headers(**options)
    )
  end

  # Determines if the given file is in the same bucket as the current one.
  private def same_bucket?(file : Lucky::Attachment::StoredFile) : Bool
    return false unless storage = file.storage.as?(S3)

    storage.bucket == bucket
  end

  # Builds a host with port from a URI object.
  private def endpoint_host_with_port(uri : URI) : String
    host, port = uri.host.to_s, uri.port
    (port && port != 80 && port != 443) ? "#{host}:#{port}" : host
  end

  # Tries to parse the S3 client's endpoint to a URI object.
  private def endpoint_uri : URI?
    return unless endpoint = raw_endpoint

    URI.parse(endpoint)
  end

  # Tries to retrieve the endpoint from the client.
  private def raw_endpoint : String?
    @client.endpoint.try(&.to_s)
  end
end
