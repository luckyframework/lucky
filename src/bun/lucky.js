import {mkdirSync, readFileSync, existsSync, rmSync, watch} from 'fs'
import {join, dirname, basename, extname} from 'path'
import {Glob} from 'bun'
import {resolvePlugins} from './plugins/index.js'

export default {
  CONFIG_PATH: 'config/bun.json',
  IGNORE_PATTERNS: [
    /^\d+$/,
    /^\.#/,
    /\.swp$/,
    /\.swo$/,
    /\.tmp$/,
    /^#.*#$/,
    /\.DS_Store$/
  ],

  root: process.cwd(),
  config: null,
  manifest: {},
  debug: false,
  dev: false,
  prod: false,
  fingerprint: false,
  minify: false,
  sourcemap: null,
  wsClients: new Set(),
  watchTimers: new Map(),
  plugins: [],

  flags(input) {
    const {debug, dev, prod, fingerprint, minify, sourcemap} =
      Array.isArray(input) ? this.parseArgv(input) : input
    if (debug != null) this.debug = debug
    if (dev != null) this.dev = dev
    if (prod != null) this.prod = prod
    if (fingerprint != null) this.fingerprint = fingerprint
    else if (prod === true) this.fingerprint = true
    if (minify != null) this.minify = minify
    else if (prod === true) this.minify = true
    if (sourcemap != null) this.sourcemap = sourcemap
  },

  SOURCEMAP_KINDS: ['inline', 'linked', 'external', 'none'],

  parseArgv(argv) {
    const opts = {}
    if (argv.includes('--debug')) opts.debug = true
    if (argv.includes('--dev')) opts.dev = true
    if (argv.includes('--prod')) opts.prod = true
    if (argv.includes('--fingerprint')) opts.fingerprint = true
    if (argv.includes('--minify')) opts.minify = true
    const sm = argv.find(a => a === '--sourcemap' || a.startsWith('--sourcemap='))
    if (sm) {
      const value = sm.includes('=') ? sm.split('=')[1] : 'linked'
      if (this.SOURCEMAP_KINDS.includes(value)) opts.sourcemap = value
      else console.warn(` ▸ Ignoring --sourcemap=${value} (valid: ${this.SOURCEMAP_KINDS.join(', ')})`)
    }
    return opts
  },

  deepMerge(target, source) {
    const result = {...target}
    for (const k of Object.keys(source))
      result[k] =
        source[k] && typeof source[k] === 'object' && !Array.isArray(source[k])
          ? this.deepMerge(target[k] || {}, source[k])
          : source[k]
    return result
  },

  loadConfig() {
    const defaults = {
      entryPoints: {js: ['src/js/app.js'], css: ['src/css/app.css']},
      plugins: {css: ['aliases', 'cssGlobs'], js: ['aliases', 'jsGlobs']},
      watchDirs: ['src/js', 'src/css', 'src/images', 'src/fonts'],
      staticDirs: ['src/images', 'src/fonts'],
      outDir: 'public/assets',
      publicPath: '/assets',
      manifestPath: 'public/bun-manifest.json',
      devServer: {host: '127.0.0.1', port: 3002, secure: false}
    }

    try {
      const json = readFileSync(join(this.root, this.CONFIG_PATH), 'utf-8')
      const user = JSON.parse(json)
      this.config = this.deepMerge(defaults, user)
      if (user.plugins != null) this.config.plugins = user.plugins
    } catch {
      this.config = defaults
    }
  },

  async loadPlugins() {
    this.plugins = await resolvePlugins(this.config.plugins, {
      root: this.root,
      config: this.config,
      dev: this.dev,
      prod: this.prod,
      fingerprint: this.fingerprint,
      minify: this.minify,
      sourcemap: this.sourcemap,
      manifest: this.manifest
    })
  },

  get outDir() {
    if (this.config == null) throw new Error(' ✖ Config is not loaded')

    return join(this.root, this.config.outDir)
  },

  fingerprintName(name, ext, content) {
    if (!this.fingerprint) return `${name}${ext}`

    const hash = Bun.hash(content).toString(16).slice(0, 8)
    return `${name}-${hash}${ext}`
  },

  async buildAssets(type, options = {}) {
    const outDir = join(this.outDir, type)
    mkdirSync(outDir, {recursive: true})

    const raw = this.config.entryPoints[type]
    const entries = Array.isArray(raw) ? raw : [raw]
    const ext = `.${type}`

    for (const entry of entries) {
      const entryPath = join(this.root, entry)
      const entryName = basename(entry).replace(/\.(ts|js|tsx|jsx|css)$/, '')

      if (!existsSync(entryPath)) {
        console.warn(` ▸ Missing entry point ${entry}, continuing...`)
        continue
      }

      let result
      try {
        result = await Bun.build({
          entrypoints: [entryPath],
          minify: this.minify,
          plugins: this.plugins,
          ...options
        })
      } catch (err) {
        console.error(` ▸ Failed to build ${entry}`)
        if (err.errors) for (const e of err.errors) console.error(e)
        else console.error(err)
        continue
      }

      if (!result.success) {
        console.error(` ▸ Failed to build ${entry}`)
        for (const log of result.logs) console.error(log)
        continue
      }

      const mainOutput = result.outputs.find(o => o.path.endsWith(ext))
      if (!mainOutput) {
        console.error(` ▸ No ${type.toUpperCase()} output for ${entry}`)
        continue
      }
      const mapOutput = result.outputs.find(o => o.kind === 'sourcemap')

      let content = await mainOutput.text()
      const fileName = this.fingerprintName(entryName, ext, content)

      if (mapOutput) {
        const mapFileName = `${fileName}.map`
        content = content.replace(
          /\/\/# sourceMappingURL=\S+/,
          () => `//# sourceMappingURL=${mapFileName}`
        )
        await Bun.write(join(outDir, mapFileName), await mapOutput.text())
      }

      await Bun.write(join(outDir, fileName), content)
      this.manifest[`${type}/${entryName}${ext}`] = `${type}/${fileName}`
    }
  },

  async buildJS() {
    await this.buildAssets('js', {
      target: 'browser',
      format: 'iife',
      sourcemap: this.sourcemap || (this.dev ? 'inline' : 'linked')
    })
  },

  async buildCSS() {
    await this.buildAssets('css')
  },

  async copyStaticAssets() {
    const glob = new Glob('**/*.*')

    for (const dir of this.config.staticDirs) {
      const fullDir = join(this.root, dir)
      if (!existsSync(fullDir)) continue

      const assetType = basename(dir)
      const destDir = join(this.outDir, assetType)

      for await (const file of glob.scan({cwd: fullDir, onlyFiles: true})) {
        const srcPath = join(fullDir, file)
        const content = await Bun.file(srcPath).arrayBuffer()

        const ext = extname(file)
        const name = file.slice(0, -ext.length) || file
        const fileName = this.fingerprintName(name, ext, new Uint8Array(content))
        const destPath = join(destDir, fileName)

        mkdirSync(dirname(destPath), {recursive: true})
        await Bun.write(destPath, content)

        this.manifest[`${assetType}/${file}`] = `${assetType}/${fileName}`
      }
    }
  },

  cleanOutDir() {
    rmSync(this.outDir, {recursive: true, force: true})
  },

  async writeManifest() {
    const manifestFullPath = join(this.root, this.config.manifestPath)
    mkdirSync(dirname(manifestFullPath), {recursive: true})
    await Bun.write(manifestFullPath, JSON.stringify(this.manifest, null, 2))
  },

  async build() {
    const env = this.prod ? 'production' : 'development'
    console.log(`Building manifest for ${env}...`)
    const start = performance.now()
    this.loadConfig()
    await this.loadPlugins()
    this.cleanOutDir()
    await this.copyStaticAssets()
    await this.buildJS()
    await this.buildCSS()
    await this.writeManifest()
    const ms = Math.round(performance.now() - start)
    console.log(`DONE  Built successfully in ${ms} ms`, this.prettyManifest())
  },

  prettyManifest() {
    const lines = Object.entries(this.manifest)
      .map(([key, value]) => `  ${key} → ${value}`)
      .join('\n')
    return `\n${lines}\n\n`
  },

  reload(type = 'full') {
    setTimeout(() => {
      const message = JSON.stringify({type})
      for (const client of this.wsClients) {
        try {
          client.send(message)
        } catch {
          this.wsClients.delete(client)
        }
      }
    }, 50)
  },

  async watch() {
    const handler = (event, filename) => {
      if (!filename) return

      let normalizedFilename = filename.replace(/\\/g, '/')

      // Vim backup files (e.g. app.css~) signal the original file changed
      if (normalizedFilename.endsWith('~'))
        normalizedFilename = normalizedFilename.slice(0, -1)

      const base = basename(normalizedFilename)
      const ext = extname(base).slice(1)

      if (this.IGNORE_PATTERNS.some(pattern => pattern.test(base))) return

      // Debounce multiple events for the same file (e.g. actual save + backup)
      if (this.watchTimers.has(normalizedFilename)) return
      this.watchTimers.set(
        normalizedFilename,
        setTimeout(() => {
          this.watchTimers.delete(normalizedFilename)
        }, 100)
      )

      console.log(` ▸ ${normalizedFilename} changed`)
      ;(async () => {
        try {
          if (ext === 'css') await this.buildCSS()
          else if (['js', 'ts', 'jsx', 'tsx'].includes(ext))
            await this.buildJS()
          else if (base.includes('.')) await this.copyStaticAssets()

          await this.writeManifest()
          this.reload(ext === 'css' ? 'css' : 'full')
        } catch (err) {
          console.error(' ✖ Build error:', err.message)
          if (err.errors) for (const e of err.errors) console.error(e)
        }
      })()
    }

    for (const dir of this.config.watchDirs) {
      const fullDir = join(this.root, dir)
      if (!existsSync(fullDir)) {
        console.warn(` ▸ Watch directory ${dir} does not exist, skipping...`)
        continue
      }
      watch(fullDir, {recursive: true}, handler)
    }

    console.log('Beginning to watch your project')
  },

  async serve() {
    await this.build()
    await this.watch()

    const {host, listenHost, port, secure} = this.config.devServer
    const hostname = listenHost || (secure ? '0.0.0.0' : host)
    const debug = this.debug
    const wsClients = this.wsClients

    Bun.serve({
      hostname,
      port,
      fetch(req, server) {
        if (server.upgrade(req)) return
        return new Response('LuckyBun WebSocket Server', {status: 200})
      },
      websocket: {
        open(ws) {
          wsClients.add(ws)
          if (debug) console.log(` ▸ Client connected (${wsClients.size})\n\n`)
        },
        close(ws) {
          wsClients.delete(ws)
          if (debug) console.log(` ▸ Client disconnected (${wsClients.size})\n\n`)
        },
        message() {}
      }
    })

    const protocol = secure ? 'wss' : 'ws'
    console.log(`\n\n    🔌 Live reload at ${protocol}://${host}:${port}\n\n`)
  },

  async bake() {
    this.dev ? await this.serve() : await this.build()
  }
}
