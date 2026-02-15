require "json"

module Bun
  struct Config
    include JSON::Serializable

    CONFIG_PATH = "./config/bun.json"

    @[JSON::Field(key: "manifestName")]
    getter manifest_name : String = "manifest.json"

    @[JSON::Field(key: "outDir")]
    getter out_dir : String = "public/assets"

    @[JSON::Field(key: "publicPath")]
    getter public_path : String = "/assets"

    @[JSON::Field(key: "staticDirs")]
    getter static_dirs : Array(String) = %w[src/images src/fonts]

    @[JSON::Field(key: "entryPoints")]
    getter entry_points : EntryPoints = EntryPoints.from_json("{}")

    @[JSON::Field(key: "devServer")]
    getter dev_server : DevServer = DevServer.from_json("{}")

    struct EntryPoints
      include JSON::Serializable

      getter js : Array(String) = %w[src/js/app.js]
      getter css : Array(String) = %w[src/css/app.css]
    end

    struct DevServer
      include JSON::Serializable

      getter host : String = "127.0.0.1"
      getter port : Int32 = 3002
      getter? secure : Bool = false

      def ws_protocol : String
        secure? ? "wss" : "ws"
      end

      def ws_url : String
        "#{ws_protocol}://#{host}:#{port}"
      end
    end

    def self.load : Config
      Config.from_json(File.read(File.expand_path(CONFIG_PATH)))
    rescue File::NotFoundError
      Config.from_json("{}")
    end
  end
end
