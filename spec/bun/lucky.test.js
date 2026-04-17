import {describe, test, expect, beforeEach, afterAll} from 'bun:test'
import {mkdirSync, writeFileSync, rmSync, existsSync, readFileSync} from 'fs'
import {join, basename} from 'path'
import LuckyBun from '../../src/bun/lucky.js'

const TEST_DIR = join(process.cwd(), '.test-tmp')

beforeEach(() => {
  rmSync(TEST_DIR, {recursive: true, force: true})
  mkdirSync(TEST_DIR, {recursive: true})
  LuckyBun.manifest = {}
  LuckyBun.config = null
  LuckyBun.plugins = []
  LuckyBun.debug = false
  LuckyBun.prod = false
  LuckyBun.dev = false
  LuckyBun.fingerprint = false
  LuckyBun.minify = false
  LuckyBun.sourcemap = null
  LuckyBun.root = TEST_DIR
})

afterAll(() => {
  rmSync(TEST_DIR, {recursive: true, force: true})
})

function createFile(relativePath, content = '') {
  const fullPath = join(TEST_DIR, relativePath)
  mkdirSync(join(fullPath, '..'), {recursive: true})
  writeFileSync(fullPath, content)
  return fullPath
}

function readOutput(relativePath) {
  return readFileSync(join(TEST_DIR, 'public/assets', relativePath), 'utf-8')
}

async function setupProject(files = {}, configOverrides = {}) {
  for (const [path, content] of Object.entries(files)) createFile(path, content)
  if (configOverrides && Object.keys(configOverrides).length)
    createFile('config/bun.json', JSON.stringify(configOverrides))
  LuckyBun.loadConfig()
  await LuckyBun.loadPlugins()
}

async function buildCSS(files, configOverrides) {
  await setupProject(files, configOverrides)
  await LuckyBun.buildCSS()
  return readOutput('css/app.css')
}

async function buildJS(files, configOverrides) {
  await setupProject(files, configOverrides)
  await LuckyBun.buildJS()
  return readOutput('js/app.js')
}

describe('flags', () => {
  test('sets known flags and ignores undefined values', () => {
    LuckyBun.flags({dev: true})
    expect(LuckyBun.dev).toBe(true)

    LuckyBun.flags({debug: true})
    expect(LuckyBun.debug).toBe(true)

    LuckyBun.dev = true
    LuckyBun.flags({prod: false})
    expect(LuckyBun.dev).toBe(true)
    expect(LuckyBun.prod).toBe(false)
  })

  test('--prod implies --fingerprint and --minify', () => {
    LuckyBun.flags({prod: true})
    expect(LuckyBun.prod).toBe(true)
    expect(LuckyBun.fingerprint).toBe(true)
    expect(LuckyBun.minify).toBe(true)
  })

  test('explicit fingerprint/minify override prod implication', () => {
    LuckyBun.flags({prod: true, minify: false})
    expect(LuckyBun.prod).toBe(true)
    expect(LuckyBun.fingerprint).toBe(true)
    expect(LuckyBun.minify).toBe(false)
  })

  test('fingerprint and minify can be set without prod', () => {
    LuckyBun.flags({fingerprint: true})
    expect(LuckyBun.prod).toBe(false)
    expect(LuckyBun.fingerprint).toBe(true)
    expect(LuckyBun.minify).toBe(false)
  })

  test('sourcemap accepts a string value', () => {
    LuckyBun.flags({sourcemap: 'external'})
    expect(LuckyBun.sourcemap).toBe('external')
  })

  test('parses argv arrays', () => {
    LuckyBun.flags(['--prod', '--sourcemap=none'])
    expect(LuckyBun.prod).toBe(true)
    expect(LuckyBun.fingerprint).toBe(true)
    expect(LuckyBun.minify).toBe(true)
    expect(LuckyBun.sourcemap).toBe('none')
  })

  test('bare --sourcemap defaults to linked', () => {
    LuckyBun.flags(['--sourcemap'])
    expect(LuckyBun.sourcemap).toBe('linked')
  })

  test('ignores invalid --sourcemap value', () => {
    LuckyBun.flags(['--sourcemap=bogus'])
    expect(LuckyBun.sourcemap).toBe(null)
  })
})

describe('deepMerge', () => {
  test('deep merges objects, replaces arrays and nulls', () => {
    expect(LuckyBun.deepMerge({a: 1, b: 2}, {b: 3, c: 4})).toEqual({
      a: 1,
      b: 3,
      c: 4
    })
    expect(
      LuckyBun.deepMerge({outer: {a: 1, b: 2}}, {outer: {b: 3, c: 4}})
    ).toEqual({outer: {a: 1, b: 3, c: 4}})
    expect(LuckyBun.deepMerge({arr: [1, 2]}, {arr: [3, 4, 5]})).toEqual({
      arr: [3, 4, 5]
    })
    expect(LuckyBun.deepMerge({a: {nested: 1}}, {a: null})).toEqual({a: null})
  })
})

describe('loadConfig', () => {
  test('uses defaults without a config file', () => {
    LuckyBun.loadConfig()
    expect(LuckyBun.config.outDir).toBe('public/assets')
    expect(LuckyBun.config.watchDirs).toEqual([
      'src/js',
      'src/css',
      'src/images',
      'src/fonts'
    ])
    expect(LuckyBun.config.entryPoints.js).toEqual(['src/js/app.js'])
    expect(LuckyBun.config.devServer.port).toBe(3002)
    expect(LuckyBun.config.plugins).toEqual({
      css: ['aliases', 'cssGlobs'],
      js: ['aliases', 'jsGlobs']
    })
  })

  test('merges user config with defaults', () => {
    createFile(
      'config/bun.json',
      JSON.stringify({outDir: 'dist', devServer: {port: 4000}})
    )

    LuckyBun.loadConfig()

    expect(LuckyBun.config.outDir).toBe('dist')
    expect(LuckyBun.config.devServer.port).toBe(4000)
    expect(LuckyBun.config.devServer.host).toBe('127.0.0.1')
    expect(LuckyBun.config.entryPoints.js).toEqual(['src/js/app.js'])
  })

  test('merges watchDirs from user config', () => {
    createFile(
      'config/bun.json',
      JSON.stringify({watchDirs: ['src/js', 'src/css']})
    )

    LuckyBun.loadConfig()

    expect(LuckyBun.config.watchDirs).toEqual(['src/js', 'src/css'])
  })

  test('merges listenHost into devServer config', () => {
    createFile(
      'config/bun.json',
      JSON.stringify({devServer: {listenHost: '0.0.0.0'}})
    )

    LuckyBun.loadConfig()

    expect(LuckyBun.config.devServer.listenHost).toBe('0.0.0.0')
    expect(LuckyBun.config.devServer.host).toBe('127.0.0.1')
  })

  test('user can override plugins', () => {
    createFile(
      'config/bun.json',
      JSON.stringify({
        plugins: {css: ['cssAliases'], js: ['config/bun/banner.js']}
      })
    )
    LuckyBun.loadConfig()

    expect(LuckyBun.config.plugins.css).toEqual(['cssAliases'])
    expect(LuckyBun.config.plugins.js).toEqual(['config/bun/banner.js'])
  })
})

describe('fingerprintName', () => {
  test('returns plain filename when fingerprint is off', () => {
    expect(LuckyBun.fingerprintName('app', '.js', 'content')).toBe('app.js')
  })

  test('returns consistent, content-dependent hashes when enabled', () => {
    LuckyBun.fingerprint = true
    const hash = LuckyBun.fingerprintName('app', '.js', 'content')
    expect(hash).toMatch(/^app-[a-f0-9]{8}\.js$/)
    expect(LuckyBun.fingerprintName('app', '.js', 'content')).toBe(hash)
    expect(LuckyBun.fingerprintName('app', '.js', 'different')).not.toBe(hash)
  })
})

describe('IGNORE_PATTERNS', () => {
  test('ignores editor artifacts and system files but allows normal files', () => {
    const ignores = f => LuckyBun.IGNORE_PATTERNS.some(p => p.test(f))

    for (const f of [
      '.#file.js',
      'file.swp',
      'file.swo',
      'file.tmp',
      '#file.js#',
      '.DS_Store',
      '12345'
    ])
      expect(ignores(f)).toBe(true)
    for (const f of ['app.js', 'styles.css', 'image.png'])
      expect(ignores(f)).toBe(false)
  })
})

describe('buildAssets', () => {
  test('builds JS files', async () => {
    await buildJS({'src/js/app.js': 'console.log("test")'})

    expect(LuckyBun.manifest['js/app.js']).toBe('js/app.js')
    expect(existsSync(join(TEST_DIR, 'public/assets/js/app.js'))).toBe(true)
  })

  test('builds CSS files', async () => {
    await buildCSS({'src/css/app.css': 'body { color: pink }'})

    expect(LuckyBun.manifest['css/app.css']).toBe('css/app.css')
    expect(existsSync(join(TEST_DIR, 'public/assets/css/app.css'))).toBe(true)
  })

  test('fingerprints when fingerprint is enabled', async () => {
    LuckyBun.fingerprint = true
    await setupProject({'src/js/app.js': 'console.log("prod")'})
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toMatch(/^js\/app-[a-f0-9]{8}\.js$/)
  })

  test('writes linked sourcemap alongside JS', async () => {
    LuckyBun.sourcemap = 'linked'
    await setupProject({'src/js/app.js': 'console.log("maps")'})
    await LuckyBun.buildJS()

    const js = readOutput('js/app.js')
    expect(existsSync(join(TEST_DIR, 'public/assets/js/app.js.map'))).toBe(true)
    expect(js).toContain('//# sourceMappingURL=app.js.map')
  })

  test('renames sourcemap and rewrites URL when fingerprinting', async () => {
    LuckyBun.fingerprint = true
    LuckyBun.sourcemap = 'linked'
    await setupProject({'src/js/app.js': 'console.log("both")'})
    await LuckyBun.buildJS()

    const fingerprinted = LuckyBun.manifest['js/app.js']
    const jsPath = join(TEST_DIR, 'public/assets', fingerprinted)
    const mapPath = `${jsPath}.map`
    expect(existsSync(jsPath)).toBe(true)
    expect(existsSync(mapPath)).toBe(true)

    const js = readFileSync(jsPath, 'utf-8')
    const mapName = basename(mapPath)
    expect(js).toContain(`//# sourceMappingURL=${mapName}`)
    expect(js).not.toContain('//# sourceMappingURL=app.js.map')
  })

  test('omits sourcemap file when set to none', async () => {
    LuckyBun.sourcemap = 'none'
    await setupProject({'src/js/app.js': 'console.log("bare")'})
    await LuckyBun.buildJS()

    expect(existsSync(join(TEST_DIR, 'public/assets/js/app.js.map'))).toBe(false)
  })

  test('warns on missing entry point and continues', async () => {
    await setupProject()
    // No src/js/app.js created — should not throw
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toBeUndefined()
  })

  test('accepts a string entry point', async () => {
    await setupProject(
      {'src/js/app.js': 'console.log("single")'},
      {entryPoints: {js: 'src/js/app.js'}}
    )
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toBe('js/app.js')
  })

  test('builds multiple JS entry points', async () => {
    await buildJS(
      {
        'src/js/app.js': 'console.log("app")',
        'src/js/admin.js': 'console.log("admin")'
      },
      {entryPoints: {js: ['src/js/app.js', 'src/js/admin.js']}}
    )

    expect(LuckyBun.manifest['js/app.js']).toBe('js/app.js')
    expect(LuckyBun.manifest['js/admin.js']).toBe('js/admin.js')
  })

  test('builds TypeScript files', async () => {
    await setupProject(
      {'src/js/app.ts': 'const msg: string = "hello"\nconsole.log(msg)'},
      {entryPoints: {js: ['src/js/app.ts']}}
    )
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toBe('js/app.js')
    expect(existsSync(join(TEST_DIR, 'public/assets/js/app.js'))).toBe(true)
    expect(readOutput('js/app.js')).toContain('hello')
  })

  test('builds TSX files', async () => {
    await setupProject(
      {
        'src/js/app.tsx': [
          'function App(): string { return "tsx works" }',
          'console.log(App())'
        ].join('\n')
      },
      {entryPoints: {js: ['src/js/app.tsx']}}
    )
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toBe('js/app.js')
    expect(existsSync(join(TEST_DIR, 'public/assets/js/app.js'))).toBe(true)
  })

  test('builds multiple CSS entry points', async () => {
    await buildCSS(
      {
        'src/css/app.css': 'body { color: red }',
        'src/css/admin.css': 'body { color: blue }'
      },
      {entryPoints: {css: ['src/css/app.css', 'src/css/admin.css']}}
    )

    expect(LuckyBun.manifest['css/app.css']).toBe('css/app.css')
    expect(LuckyBun.manifest['css/admin.css']).toBe('css/admin.css')
  })
})

describe('copyStaticAssets', () => {
  async function copyAssets(files = {}, config = {}) {
    await setupProject(files, config)
    await LuckyBun.copyStaticAssets()
  }

  test('copies images and fonts, preserving nested structure', async () => {
    await copyAssets({
      'src/images/logo.png': 'fake-image-data',
      'src/images/icons/arrow.svg': '<svg/>',
      'src/fonts/Inter.woff2': 'fake-font-data'
    })

    expect(LuckyBun.manifest['images/logo.png']).toBe('images/logo.png')
    expect(LuckyBun.manifest['images/icons/arrow.svg']).toBeDefined()
    expect(LuckyBun.manifest['fonts/Inter.woff2']).toBe('fonts/Inter.woff2')
    expect(existsSync(join(TEST_DIR, 'public/assets/images/logo.png'))).toBe(
      true
    )
    expect(
      existsSync(join(TEST_DIR, 'public/assets/images/icons/arrow.svg'))
    ).toBe(true)
  })

  test('fingerprints static assets when fingerprint is enabled', async () => {
    LuckyBun.fingerprint = true
    await copyAssets({'src/images/logo.png': 'fake-image-data'})

    expect(LuckyBun.manifest['images/logo.png']).toMatch(
      /^images\/logo-[a-f0-9]{8}\.png$/
    )
  })

  test('skips missing static directories', async () => {
    await copyAssets()

    expect(Object.keys(LuckyBun.manifest)).toHaveLength(0)
  })
})

describe('cleanOutDir', () => {
  test('removes output directory and does not throw if already absent', async () => {
    createFile('public/assets/js/old.js', 'old')
    await setupProject()
    LuckyBun.cleanOutDir()

    expect(existsSync(join(TEST_DIR, 'public/assets'))).toBe(false)
    expect(() => LuckyBun.cleanOutDir()).not.toThrow()
  })
})

describe('writeManifest', () => {
  test('writes manifest JSON', async () => {
    await setupProject()
    LuckyBun.manifest = {'js/app.js': 'js/app-abc123.js'}
    await LuckyBun.writeManifest()
    const content = readFileSync(
      join(TEST_DIR, LuckyBun.config.manifestPath),
      'utf-8'
    )

    expect(JSON.parse(content)).toEqual({'js/app.js': 'js/app-abc123.js'})
  })
})

describe('outDir', () => {
  test('throws if config not loaded', () => {
    LuckyBun.config = null

    expect(() => LuckyBun.outDir).toThrow('Config is not loaded')
  })

  test('returns full path when config loaded', () => {
    LuckyBun.loadConfig()

    expect(LuckyBun.outDir).toBe(join(TEST_DIR, 'public/assets'))
  })
})

describe('loadPlugins', () => {
  test('loads default plugins', async () => {
    LuckyBun.loadConfig()
    await LuckyBun.loadPlugins()

    expect(LuckyBun.plugins).toHaveLength(2)
    expect(
      LuckyBun.plugins.find(p => p.name === 'css-transforms')
    ).toBeDefined()
    expect(LuckyBun.plugins.find(p => p.name === 'js-transforms')).toBeDefined()
  })

  test('loads no plugins when config is empty', async () => {
    createFile('config/bun.json', JSON.stringify({plugins: {}}))
    LuckyBun.loadConfig()
    await LuckyBun.loadPlugins()

    expect(LuckyBun.plugins).toHaveLength(0)
  })

  test('handles unknown built-in plugin gracefully', async () => {
    createFile(
      'config/bun.json',
      JSON.stringify({plugins: {css: ['nonExistent']}})
    )
    LuckyBun.loadConfig()
    await LuckyBun.loadPlugins()

    expect(LuckyBun.plugins).toHaveLength(0)
  })

  test('loads custom plugin from path', async () => {
    createFile(
      'config/bun/uppercase.js',
      `export default function() {
        return content => content.toUpperCase()
      }`
    )
    createFile(
      'config/bun.json',
      JSON.stringify({plugins: {css: ['config/bun/uppercase.js']}})
    )
    LuckyBun.loadConfig()
    await LuckyBun.loadPlugins()

    expect(LuckyBun.plugins).toHaveLength(1)
    expect(LuckyBun.plugins[0].name).toBe('css-transforms')
  })
})

describe('aliases plugin', () => {
  test('replaces $/ references with root path in CSS url()', async () => {
    const content = await buildCSS({
      'src/css/app.css': [
        "body { background: url('$/src/images/bg.png'); }",
        ".icon { background: url('$/src/images/icon.svg'); }"
      ].join('\n'),
      'src/images/bg.png': 'fake',
      'src/images/icon.svg': '<svg/>'
    })

    // The alias is resolved and Bun inlines the assets as data URIs
    expect(content).not.toContain('$/')
    expect(content).toContain('url(')
  })

  test('replaces $/ references in JS imports', async () => {
    const content = await buildJS({
      'src/js/app.js': "import utils from '$/lib/utils.js'\nconsole.log(utils)",
      'lib/utils.js': 'export default 42'
    })

    expect(content).not.toContain('$/')
    expect(content).toContain('42')
  })

  test('replaces $/ references in CSS @import', async () => {
    const content = await buildCSS({
      'src/css/app.css': "@import '$/lib/reset.css';",
      'lib/reset.css': '* { margin: 0 }'
    })

    expect(content).not.toContain('$/')
    expect(content).toContain('margin')
  })

  test('leaves non-alias urls untouched', async () => {
    const content = await buildCSS({
      'src/css/app.css':
        "body { background: url('https://example.com/bg.png'); }"
    })

    expect(content).toContain('https://example.com/bg.png')
  })

  test('replaces $/ references in TypeScript imports', async () => {
    await setupProject(
      {
        'src/js/app.ts':
          "import utils from '$/lib/utils.ts'\nconsole.log(utils)",
        'lib/utils.ts': 'const val: number = 99\nexport default val'
      },
      {entryPoints: {js: ['src/js/app.ts']}}
    )
    await LuckyBun.buildJS()
    const content = readOutput('js/app.js')

    expect(content).not.toContain('$/')
    expect(content).toContain('99')
  })

  test('leaves non-alias imports untouched', async () => {
    const content = await buildJS({
      'src/js/app.js': "import {x} from './utils.js'\nconsole.log(x)",
      'src/js/utils.js': 'export const x = 42'
    })

    expect(content).toContain('42')
  })

  test('resolves $/ inside prefixed strings like glob:$/', async () => {
    const aliases = (await import('../../src/bun/plugins/aliases.js')).default
    const transform = aliases({root: '/root'})
    const result = transform("import c from 'glob:$/lib/components/*.js'")

    expect(result).toBe("import c from 'glob:/root/lib/components/*.js'")
  })

  test('does not replace $/ inside regex literals', async () => {
    const aliases = (await import('../../src/bun/plugins/aliases.js')).default
    const transform = aliases({root: '/root'})
    const input = "s.replace(/.*components\\//, '').replace(/_component$/, '')"
    const result = transform(input)

    expect(result).toBe(input)
  })

  test('does not match $/ preceded by a word character', async () => {
    const content = await buildJS({
      'src/js/app.js': [
        "const el = document.querySelector('div')",
        "const path = '/api/test'",
        'console.log(el, path)'
      ].join('\n')
    })

    expect(content).not.toContain(TEST_DIR)
  })
})

describe('cssGlobs plugin', () => {
  test('expands glob @import with flat wildcard', async () => {
    const content = await buildCSS({
      'src/css/app.css': "@import './components/*.css';",
      'src/css/components/button.css': '.button { color: red }',
      'src/css/components/card.css': '.card { color: blue }'
    })

    expect(content).toContain('.button')
    expect(content).toContain('.card')
  })

  test('expands glob @import with ** recursive wildcard', async () => {
    const content = await buildCSS({
      'src/css/app.css': "@import './components/**/*.css';",
      'src/css/components/button.css': '.button { color: red }',
      'src/css/components/forms/input.css': '.input { color: green }',
      'src/css/components/forms/select.css': '.select { color: blue }'
    })

    expect(content).toContain('.button')
    expect(content).toContain('.input')
    expect(content).toContain('.select')
  })

  test('does not import the file itself', async () => {
    const content = await buildCSS({
      'src/css/app.css': "@import './*.css';",
      'src/css/other.css': '.other { color: red }'
    })

    expect(content).toContain('.other')
  })

  test('handles glob matching no files', async () => {
    await buildCSS({
      'src/css/app.css': "@import './empty/**/*.css';",
      'src/css/empty/.gitkeep': ''
    })
  })

  test('preserves non-glob imports', async () => {
    const content = await buildCSS({
      'src/css/app.css':
        "@import './reset.css';\n@import './components/*.css';",
      'src/css/reset.css': '* { margin: 0 }',
      'src/css/components/button.css': '.button { color: red }'
    })

    expect(content).toContain('margin')
    expect(content).toContain('.button')
  })

  test('expands globs in deterministic sorted order', async () => {
    const content = await buildCSS({
      'src/css/app.css': "@import './components/*.css';",
      'src/css/components/zebra.css': '.zebra { order: 3 }',
      'src/css/components/alpha.css': '.alpha { order: 1 }',
      'src/css/components/middle.css': '.middle { order: 2 }'
    })
    const alphaPos = content.indexOf('.alpha')
    const middlePos = content.indexOf('.middle')
    const zebraPos = content.indexOf('.zebra')

    expect(alphaPos).toBeLessThan(middlePos)
    expect(middlePos).toBeLessThan(zebraPos)
  })

  test('excludes paths matching not clause', async () => {
    const content = await buildCSS({
      'src/css/app.css':
        "@import './components/**/*.css' not './components/admin/**';",
      'src/css/components/button.css': '.button { color: red }',
      'src/css/components/admin/panel.css': '.panel { color: blue }',
      'src/css/components/forms/input.css': '.input { color: pink }'
    })

    expect(content).toContain('.button')
    expect(content).toContain('.input')
    expect(content).not.toContain('.panel')
  })

  test('supports multiple not clauses', async () => {
    const content = await buildCSS({
      'src/css/app.css': [
        "@import './components/**/*.css'",
        "  not './components/admin/**'",
        "  not './components/internal/**';"
      ].join('\n'),
      'src/css/components/button.css': '.button { color: red }',
      'src/css/components/admin/panel.css': '.admin { color: blue }',
      'src/css/components/internal/debug.css': '.debug { color: green }'
    })

    expect(content).toContain('.button')
    expect(content).not.toContain('.admin')
    expect(content).not.toContain('.debug')
  })
})

describe('jsGlobs plugin', () => {
  const jsGlobsConfig = {plugins: {js: ['jsGlobs']}}

  function jsApp(...lines) {
    return {'src/js/app.js': lines.join('\n')}
  }

  async function buildJSGlobs(files) {
    return buildJS(files, jsGlobsConfig)
  }

  test('expands glob import into named exports', async () => {
    const content = await buildJSGlobs({
      ...jsApp(
        "import components from 'glob:./components/*.js'",
        'console.log(components)'
      ),
      'src/js/components/modal.js': 'export default function modal() {}',
      'src/js/components/dropdown.js': 'export default function dropdown() {}'
    })

    expect(content).toContain('modal')
    expect(content).toContain('dropdown')
  })

  test('expands recursive glob with relative path keys', async () => {
    const content = await buildJSGlobs({
      ...jsApp(
        "import controllers from 'glob:./controllers/**/*.js'",
        'console.log(Object.keys(controllers))'
      ),
      'src/js/controllers/nav.js': 'export default function nav() {}',
      'src/js/controllers/forms/input.js': 'export default function input() {}'
    })

    expect(content).toContain('nav')
    expect(content).toContain('forms/input')
  })

  test('avoids naming clashes for same-named files in different dirs', async () => {
    const content = await buildJSGlobs({
      ...jsApp(
        "import modules from 'glob:./components/**/*.js'",
        'console.log(Object.keys(modules))'
      ),
      'src/js/components/nav.js': 'export default function nav() {}',
      'src/js/components/admin/nav.js': 'export default function adminNav() {}'
    })

    expect(content).toContain('nav')
    expect(content).toContain('admin/nav')
  })

  test('handles glob matching no files', async () => {
    const content = await buildJSGlobs({
      ...jsApp(
        "import components from 'glob:./components/*.js'",
        'console.log(components)'
      ),
      'src/js/components/.gitkeep': ''
    })

    expect(content).toBeDefined()
  })

  test('leaves non-glob imports untouched', async () => {
    const content = await buildJSGlobs({
      ...jsApp(
        "import {something} from './utils.js'",
        'console.log(something)'
      ),
      'src/js/utils.js': 'export const something = 42'
    })

    expect(content).toContain('42')
  })

  test('handles multiple glob imports', async () => {
    const content = await buildJSGlobs({
      ...jsApp(
        "import data from 'glob:./data/*.js'",
        "import stores from 'glob:./stores/*.js'",
        'console.log(data, stores)'
      ),
      'src/js/data/counter.js': 'export default function counter() {}',
      'src/js/stores/auth.js': 'export default function auth() {}'
    })

    expect(content).toContain('counter')
    expect(content).toContain('auth')
  })

  test('avoids variable collisions across multiple globs with same filenames', async () => {
    const content = await buildJSGlobs({
      ...jsApp(
        "import components from 'glob:./components/*.js'",
        "import widgets from 'glob:./widgets/*.js'",
        'console.log(components, widgets)'
      ),
      'src/js/components/theme.js':
        'export default function componentTheme() { return "component" }',
      'src/js/widgets/theme.js':
        'export default function widgetTheme() { return "widget" }'
    })

    expect(content).toContain('component')
    expect(content).toContain('widget')
  })

  test('expands globs in deterministic sorted order', async () => {
    const content = await buildJSGlobs({
      ...jsApp(
        "import components from 'glob:./components/*.js'",
        'for (const [k, v] of Object.entries(components)) console.log(k)'
      ),
      'src/js/components/zebra.js': 'export default function zebra() {}',
      'src/js/components/alpha.js': 'export default function alpha() {}',
      'src/js/components/middle.js': 'export default function middle() {}'
    })
    const alphaPos = content.indexOf('alpha')
    const middlePos = content.indexOf('middle')
    const zebraPos = content.indexOf('zebra')

    expect(alphaPos).toBeLessThan(middlePos)
    expect(middlePos).toBeLessThan(zebraPos)
  })

  test('excludes paths matching not clause', async () => {
    const content = await buildJSGlobs({
      ...jsApp(
        "import c from 'glob:./components/**/*.js not ./components/admin/**'",
        'console.log(c)'
      ),
      'src/js/components/modal.js': 'export default function modal() {}',
      'src/js/components/admin/nav.js': 'export default function adminNav() {}'
    })

    expect(content).toContain('modal')
    expect(content).not.toContain('adminNav')
  })

  test('handles absolute glob paths with exclusions', async () => {
    const absComponents = join(TEST_DIR, 'app/components')
    const content = await buildJSGlobs({
      ...jsApp(
        `import c from 'glob:${absComponents}/**/*_component.js not ${absComponents}/admin/**'`,
        'console.log(c)'
      ),
      'app/components/modal_component.js': 'export default function modal() {}',
      'app/components/admin/panel_component.js':
        'export default function panel() {}'
    })

    expect(content).toContain('modal')
    expect(content).not.toContain('panel')
  })
})

describe('plugin pipeline', () => {
  test('css plugins run in configured order', async () => {
    const content = await buildCSS({
      'src/css/app.css':
        "@import './components/*.css';\nbody { background: url('$/src/images/bg.png'); }",
      'src/css/components/button.css': '.button { color: red }',
      'src/images/bg.png': 'fake'
    })

    expect(content).not.toContain('$/')
    expect(content).toContain('.button')
  })

  test('disabling all plugins still builds valid output', async () => {
    const css = await buildCSS(
      {'src/css/app.css': 'body { color: red }'},
      {plugins: {}}
    )
    expect(css).toContain('color')

    const js = await buildJS(
      {'src/js/app.js': 'console.log("hello")'},
      {plugins: {}}
    )
    expect(js).toContain('hello')
  })
})

describe('full build', () => {
  test('runs the complete build pipeline', async () => {
    await setupProject({
      'src/js/app.js': 'console.log("built")',
      'src/css/app.css': 'body { color: red }',
      'src/images/logo.png': 'fake-image'
    })
    LuckyBun.cleanOutDir()
    await LuckyBun.copyStaticAssets()
    await LuckyBun.buildJS()
    await LuckyBun.buildCSS()
    await LuckyBun.writeManifest()

    expect(LuckyBun.manifest['js/app.js']).toBeDefined()
    expect(LuckyBun.manifest['css/app.css']).toBeDefined()
    expect(LuckyBun.manifest['images/logo.png']).toBeDefined()
    expect(existsSync(join(TEST_DIR, LuckyBun.config.manifestPath))).toBe(true)
  })

  test('clean build removes previous output', async () => {
    createFile('public/assets/js/stale.js', 'old stuff')
    await setupProject({'src/js/app.js': 'console.log("fresh")'})
    LuckyBun.cleanOutDir()
    await LuckyBun.buildJS()

    expect(existsSync(join(TEST_DIR, 'public/assets/js/stale.js'))).toBe(false)
    expect(existsSync(join(TEST_DIR, 'public/assets/js/app.js'))).toBe(true)
  })
})

describe('prettyManifest', () => {
  test('formats manifest entries and handles empty manifest', () => {
    LuckyBun.manifest = {
      'js/app.js': 'js/app-abc123.js',
      'css/app.css': 'css/app-def456.css'
    }
    const output = LuckyBun.prettyManifest()
    expect(output).toContain('js/app.js → js/app-abc123.js')
    expect(output).toContain('css/app.css → css/app-def456.css')

    LuckyBun.manifest = {}
    expect(LuckyBun.prettyManifest()).toContain('\n')
  })
})
