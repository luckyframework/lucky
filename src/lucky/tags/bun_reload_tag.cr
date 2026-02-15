module Lucky::BunReloadTag
  # Renders a live reload tag which connects to Bun's WebSocket server.
  #
  # NOTE: This tag only generates output in development, so there is no need to
  # render it conditionally.
  #
  def bun_reload_connect_tag
    return unless LuckyEnv.development?

    config = LuckyBun::Config.load
    tag "script" do
      raw <<-JS
      (() => {
        const cssPaths = #{bun_reload_connect_css_files(config).to_json};
        const ws = new WebSocket('#{config.dev_server.ws_url}')

        ws.onmessage = (event) => {
          const data = JSON.parse(event.data)

          if (data.type === 'css') {
            document.querySelectorAll('link[rel="stylesheet"]').forEach(link => {
              const linkPath = new URL(link.href).pathname.split('?')[0]
              if (cssPaths.some(p => linkPath.startsWith(p))) {
                const url = new URL(link.href)
                url.searchParams.set('r', Date.now())
                link.href = url.toString()
              }
            })
            console.log('▸ CSS reloaded')
          } else if (data.type === 'error') {
            console.error('✖ Build error:', data.message)
          } else {
            console.log('▸ Reloading...')
            location.reload()
          }
        }

        ws.onopen = () => console.log('▸ Live reload connected')
        ws.onclose = () => setTimeout(() => location.reload(), 2000)
      })()
      JS
    end
  end

  # Collects all CSS entrypoints at their public paths.
  private def bun_reload_connect_css_files(
    config : LuckyBun::Config,
  ) : Array(String)
    Lucky::AssetHelpers.css_entry_points.map do |key|
      File.join(config.public_path, key)
    end
  end
end
