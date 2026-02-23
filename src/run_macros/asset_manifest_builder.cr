require "json"
require "colorize"
require "../bun/config"

struct AssetManifestBuilder
  enum Source
    Bun
    Mix
    Vite
  end

  property retries = 0

  @manifest_path : String
  @source : Source
  @max_retries : Int32
  @retry_after : Float64
  @bun_config : LuckyBun::Config?

  def initialize(@source : Source = Source::Bun, manifest_file : String = "")
    @manifest_path = resolve_manifest_path(manifest_file)

    # These values can be configured at compile time via environment variables:
    # - LUCKY_ASSET_MANIFEST_RETRY_COUNT: Number of times to retry (default: 20)
    # - LUCKY_ASSET_MANIFEST_RETRY_DELAY: Delay between retries in seconds (default: 0.25)
    @max_retries = ENV["LUCKY_ASSET_MANIFEST_RETRY_COUNT"]?.try(&.to_i) || 20
    @retry_after = ENV["LUCKY_ASSET_MANIFEST_RETRY_DELAY"]?.try(&.to_f) || 0.25
  end

  # Tries to build a manifest from the chosen bundler and retries several times
  # when it fails.
  def build_with_retry
    retry_or_raise_error unless File.exists?(@manifest_path)

    case @source
    in .bun?  then build_bun_manifest
    in .mix?  then build_mix_manifest
    in .vite? then build_vite_manifest
    end
  end

  # Tracks retries and raises if maximum allowed retries are exceeded.
  private def retry_or_raise_error
    raise_missing_manifest_error unless retries < @max_retries

    self.retries += 1
    sleep @retry_after
    build_with_retry
  end

  # Builds an internal asset manifest from Bun's generated manifest file.
  #
  # NOTE: Bun's manifest uses values are filenames relative to the output
  # directory, so we need to prepend the public_path from `LuckyBun::Config`
  # (defaults to "/assets").
  #
  private def build_bun_manifest
    config = bun_config
    JSON.parse(File.read(@manifest_path)).as_h.each do |key, value|
      path = File.join(config.public_path, value.as_s)
      puts %({% ::Lucky::AssetHelpers::ASSET_MANIFEST["#{key}"] = "#{path}" %})
    end
  end

  # Builds an internal asset manifest from Laravel Mix's generated manifest
  # file. Keys are prefixed with "/" and optionally "assets/" that we strip.
  #
  private def build_mix_manifest
    JSON.parse(File.read(@manifest_path)).as_h.each do |key, value|
      clean_key = key.gsub(/^\//, "").gsub(/^assets\//, "")
      puts %({% ::Lucky::AssetHelpers::ASSET_MANIFEST["#{clean_key}"] = "#{value.as_s}" %})
    end
  end

  # Builds an internal asset manifest from Vite's generated manifest files.
  #
  # NOTE: Vite has two manifest formats:
  # Dev manifest (from vite-plugin-dev-manifest):
  #   `{ "url": "http://localhost:5173/", "inputs": { "src/js/app.js": "src/js/app.js" } }`
  # Production manifest:
  #   `{ "src/js/app.js": { "file": "assets/app.abc123.js", "src": "src/js/app.js" } }`
  #
  private def build_vite_manifest
    manifest = JSON.parse(File.read(@manifest_path))

    if manifest.as_h.has_key?("url") && manifest.as_h.has_key?("inputs")
      build_vite_dev_manifest(manifest)
    else
      build_vite_prod_manifest(manifest)
    end
  end

  # Builds an internal asset manifest from Vite's generated development
  # manifest file.
  private def build_vite_dev_manifest(manifest)
    base_url = manifest["url"].as_s
    manifest["inputs"].as_h.each do |_, value|
      path = value.as_s
      clean_key = path.starts_with?("src/") ? path[4..] : path
      puts %({% ::Lucky::AssetHelpers::ASSET_MANIFEST["#{clean_key}"] = "#{base_url}#{path}" %})
    end
  end

  # Builds an internal asset manifest from Vite's generated production manifest
  # file.
  private def build_vite_prod_manifest(manifest)
    manifest.as_h.each do |key, value|
      next if key.starts_with?("_")

      if value.as_h.has_key?("src")
        clean_key = key.starts_with?("src/") ? key[4..] : key
        puts %({% ::Lucky::AssetHelpers::ASSET_MANIFEST["#{clean_key}"] = "/#{value["file"].as_s}" %})
      end
    end
  end

  # Resolves the full path of the asset manifest file based on the selected
  # bundler, with a fallback to defaults.
  private def resolve_manifest_path(file : String) : String
    path = case @source
           in .bun?
             bun_config.manifest_path
           in .mix?
             file.blank? ? "./public/mix-manifest.json" : file
           in .vite?
             file.blank? ? "./public/.vite/manifest.json" : file
           end

    File.expand_path(path)
  end

  # Loads and memoizes the shared config between Bun and Lucky.
  private def bun_config : LuckyBun::Config
    @bun_config ||= LuckyBun::Config.load
  end

  # Renders a helpful message and raises an error if the asset manifest file
  # could not be found.
  private def raise_missing_manifest_error
    message = case @source
              in .bun?
                <<-ERROR
                #{"Manifest not found:".colorize(:red)} #{@manifest_path}

                #{"Make sure you have compiled your assets:".colorize(:yellow)}
                  bun run dev     # start development server with watcher
                  bun run build   # normal build
                  bun run prod    # minified and fingerprinted build

                ERROR
              in .mix?
                <<-ERROR
                #{"Manifest not found:".colorize(:red)} #{@manifest_path}

                #{"Make sure you have compiled your assets:".colorize(:yellow)}
                  yarn run mix         # development build
                  yarn run mix watch   # development build with watcher
                  yarn run mix --production  # production build

                ERROR
              in .vite?
                <<-ERROR
                #{"Manifest not found:".colorize(:red)} #{@manifest_path}

                #{"Make sure you have compiled your assets:".colorize(:yellow)}
                  npx vite        # start development server
                  npx vite build  # production build

                ERROR
              end

    puts message
    raise "Asset manifest not found"
  end
end

begin
  source = AssetManifestBuilder::Source.parse(ARGV[0]? || "bun")
  manifest_file = ARGV[1]? || ""

  AssetManifestBuilder.new(source, manifest_file).build_with_retry
rescue e
  puts e.message.try(&.colorize(:red))
  raise e
end
