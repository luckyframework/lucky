require "json"
require "colorize"
require "../lucky/asset_manifest"

class GetFingerprintedAsset
  RETRY_AFTER = 0.25

  private getter requested_asset_path
  property retries
  @retries : Int32 = 0

  def initialize(@requested_asset_path : String)
  end

  def self.find_with_retry(requested_asset_path : String) : String?
    new(requested_asset_path).find_with_retry
  end

  def find_with_retry : String?
    if manifest_exists?
      find || retry_or_raise_error
    else
      retry_or_raise_error
    end
  end

  private def find : String?
    Lucky::AssetManifest.fingerpinted_path_for(requested_asset_path)
  end

  private def retry_or_raise_error : String?
    if retries < max_retries
      self.retries += 1
      sleep(RETRY_AFTER)
      find_with_retry
    elsif manifest_exists?
      nil # We couldn't find a matching path after max_retries
    else
      raise_missing_manifest_error
    end
  end

  private def manifest_exists?
    File.exists?(Lucky::AssetManifest::MANIFEST_PATH)
  end

  private def max_retries : Int32
    seconds_to_wait = ENV["ASSET_HELPER_TIMEOUT_IN_SECONDS"]?.try(&.to_i) || 5
    (seconds_to_wait / RETRY_AFTER).to_i
  end

  private def raise_missing_manifest_error
    puts "Manifest at #{Lucky::AssetManifest::MANIFEST_PATH} does not exist".colorize(:red)
    puts "Make sure you have compiled your assets".colorize(:red)
  end
end

begin
  requested_asset_path = ARGV.first
  puts GetFingerprintedAsset.find_with_retry(requested_asset_path)
rescue ex
  puts ex.message.colorize(:red)
  raise ex
end
