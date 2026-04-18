module Lucky::BunReloadTag
  # Renders a live reload tag which connects to Bun's WebSocket server.
  #
  # NOTE: This tag only generates output in development, so there is no need to
  # render it conditionally.
  #
  def bun_reload_connect_tag
    return unless LuckyEnv.development?

    tag "script" do
      raw <<-JS
      (() => {
        const cssPaths = #{bun_reload_connect_css_files.to_json};
        const ws = new WebSocket('#{LuckyBun::Config.instance.dev_server.ws_url}')
        let connected = false

        const scrollKey = 'bun-scroll:' + location.pathname
        addEventListener('load', () => {
          const saved = sessionStorage.getItem(scrollKey)
          if (saved !== null) {
            sessionStorage.removeItem(scrollKey)
            scrollTo(0, parseInt(saved, 10))
          }
        })
        const reload = () => {
          sessionStorage.setItem(scrollKey, String(scrollY))
          location.reload()
        }

        ws.onmessage = (event) => {
          const data = JSON.parse(event.data)

          if (data.type === 'css') {
            document.querySelectorAll('link[rel="stylesheet"]').forEach(link => {
              const linkPath = new URL(link.href).pathname.split('?')[0]
              if (cssPaths.some(p => linkPath.startsWith(p))) {
                const url = new URL(link.href)
                url.searchParams.set('bust', Date.now())
                link.href = url.toString()
              }
            })
            console.log('▸ CSS reloaded')
          } else if (data.type === 'error') {
            console.error('✖ Build error:', data.message)
          } else {
            console.log('▸ Reloading...')
            reload()
          }
        }

        ws.onopen = () => {
          connected = true
          console.log('▸ Live reload connected')
        }
        ws.onclose = () => {
          if (connected) setTimeout(reload, 2000)
        }
      })()
      JS
    end
  end

  # Collects all CSS entrypoints at their public paths.
  private def bun_reload_connect_css_files : Array(String)
    Lucky::AssetHelpers.css_entry_points.map do |key|
      File.join(LuckyBun::Config.instance.public_path, key)
    end
  end
end
