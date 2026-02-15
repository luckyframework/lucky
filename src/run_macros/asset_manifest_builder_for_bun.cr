require "json"
require "colorize"
require "../bun/config"

struct AssetManifestBuilder
  property retries = 0
  @manifest_path : String
  @config : LuckyBun::Config
  @max_retries : Int32
  @retry_after : Float64

  def initialize
    @config = LuckyBun::Config.load
    @manifest_path = File.expand_path(@config.manifest_path)

    # These values can be configured at compile time via environment variables:
    # - LUCKY_ASSET_MANIFEST_RETRY_COUNT: Number of times to retry (default: 20)
    # - LUCKY_ASSET_MANIFEST_RETRY_DELAY: Delay between retries in seconds (default: 0.25)
    @max_retries = ENV["LUCKY_ASSET_MANIFEST_RETRY_COUNT"]?.try(&.to_i) || 20
    @retry_after = ENV["LUCKY_ASSET_MANIFEST_RETRY_DELAY"]?.try(&.to_f) || 0.25
  end

  def build_with_retry
    retry_or_raise_error unless File.exists?(@manifest_path)
    build_manifest
  end

  private def retry_or_raise_error
    raise_missing_manifest_error unless retries < @max_retries

    self.retries += 1
    sleep @retry_after
    build_with_retry
  end

  private def build_manifest
    JSON.parse(File.read(@manifest_path)).as_h.each do |key, value|
      path = expand_asset_path(value.as_s)
      puts %({% ::Lucky::AssetHelpers::ASSET_MANIFEST["#{key}"] = "#{path}" %})
    end
  end

  private def expand_asset_path(file : String) : String
    File.join(@config.public_path, file)
  end

  private def raise_missing_manifest_error
    message = <<-ERROR
    #{"Manifest not found:".colorize(:red)} #{@manifest_path}

    #{"Make sure you have compiled your assets:".colorize(:yellow)}
      bun run dev     # start development server with watcher
      bun run build   # normal build
      bun run prod    # minified and fingerprinted build

    ERROR

    puts message
    raise "Asset manifest not found"
  end
end

begin
  AssetManifestBuilder.new.build_with_retry
rescue e
  puts e.message.try(&.colorize(:red))
  raise e
end
