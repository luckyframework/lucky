require "json"
require "yaml"
require "colorize"

class AssetManifestBuilder
  MANIFEST_PATH       = File.expand_path("./public/mix-manifest.json")
  WATCH_PATH          = File.expand_path("./config/watch.yml")
  MAX_RETRIES         =   20
  DEFAULT_RETRY_AFTER = 0.25

  property retries
  @retries : Int32 = 0

  @retry_interval : Float64? = nil

  def self.build_with_retry
    new.build_with_retry
  end

  def build_with_retry
    if manifest_exists?
      build
    else
      retry_or_raise_error
    end
  end

  private def retry_interval
    @retry_interval ||= ->{
      if watch_config_exists?
        value = read_retry_interval || DEFAULT_RETRY_AFTER
      else
        value = DEFAULT_RETRY_AFTER
      end
      value / MAX_RETRIES
    }.call
  end

  private def read_retry_interval
    watch_file = File.read(WATCH_PATH)
    seconds = YAML.parse(watch_file)["retry_seconds"]?
    seconds ? seconds.to_s.to_f : nil
  end

  private def retry_or_raise_error
    if retries < MAX_RETRIES
      self.retries += 1
      sleep(retry_interval)
      build_with_retry
    else
      raise_missing_manifest_error
    end
  end

  private def build
    manifest_file = File.read(MANIFEST_PATH)
    manifest = JSON.parse(manifest_file)

    manifest.as_h.each do |key, value|
      key = key.gsub(/^\//, "").gsub(/^assets\//, "")
      puts %({% ::Lucky::AssetHelpers::ASSET_MANIFEST["#{key}"] = "#{value.as_s}" %})
    end
  end

  private def manifest_exists?
    File.exists?(MANIFEST_PATH)
  end

  private def watch_config_exists?
    File.exists?(WATCH_PATH)
  end

  private def raise_missing_manifest_error
    puts "Manifest at #{AssetManifestBuilder::MANIFEST_PATH} does not exist".colorize(:red)
    puts "Make sure you have compiled your assets".colorize(:red)
  end
end

begin
  AssetManifestBuilder.build_with_retry
rescue ex
  puts ex.message.colorize(:red)
  raise ex
end
