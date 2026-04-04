require "../spec_helper"

describe LuckyBun::Config do
  it "uses defaults without a config file" do
    config = LuckyBun::Config.from_json("{}")

    config.dev_server.host.should eq("127.0.0.1")
    config.dev_server.port.should eq(3002)
    config.dev_server.secure?.should be_false
    config.dev_server.ws_url.should eq("ws://127.0.0.1:3002")
    config.entry_points.css.should eq(%w[src/css/app.css])
    config.entry_points.js.should eq(%w[src/js/app.js])
    config.manifest_path.should eq("public/bun-manifest.json")
    config.out_dir.should eq("public/assets")
    config.public_path.should eq("/assets")
    config.static_dirs.should eq(%w[src/images src/fonts])
  end

  it "accepts string entry points" do
    config = LuckyBun::Config.from_json(
      %({"entryPoints": {"js": "src/js/app.ts", "css": "src/css/app.css"}})
    )

    config.entry_points.js.should eq(%w[src/js/app.ts])
    config.entry_points.css.should eq(%w[src/css/app.css])
  end

  it "accepts array entry points" do
    config = LuckyBun::Config.from_json(
      %({"entryPoints": {"js": ["src/js/app.js", "src/js/admin.js"]}})
    )

    config.entry_points.js.should eq(%w[src/js/app.js src/js/admin.js])
  end

  it "supports secure websocket url" do
    config = LuckyBun::Config.from_json(%({"devServer": {"secure": true}}))

    config.dev_server.ws_protocol.should eq("wss")
    config.dev_server.ws_url.should eq("wss://127.0.0.1:3002")
  end
end
