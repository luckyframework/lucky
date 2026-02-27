import {describe, test, expect, beforeEach, afterAll} from 'bun:test'
import {mkdirSync, writeFileSync, rmSync, existsSync, readFileSync} from 'fs'
import {join} from 'path'
import LuckyBun from '../../src/bun/lucky.js'

const TEST_DIR = join(process.cwd(), '.test-tmp')

beforeEach(() => {
  rmSync(TEST_DIR, {recursive: true, force: true})
  mkdirSync(TEST_DIR, {recursive: true})
  LuckyBun.manifest = {}
  LuckyBun.config = null
  LuckyBun.plugins = []
  LuckyBun.prod = false
  LuckyBun.dev = false
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

async function setupProject(files = {}, configOverrides = {}) {
  for (const [path, content] of Object.entries(files)) createFile(path, content)
  if (configOverrides && Object.keys(configOverrides).length)
    createFile('config/bun.json', JSON.stringify(configOverrides))
  LuckyBun.loadConfig()
  await LuckyBun.loadPlugins()
}

describe('flags', () => {
  test('sets dev flag', () => {
    LuckyBun.flags({dev: true})
    expect(LuckyBun.dev).toBe(true)
  })

  test('sets prod flag', () => {
    LuckyBun.flags({prod: true})
    expect(LuckyBun.prod).toBe(true)
  })

  test('ignores undefined values', () => {
    LuckyBun.dev = true
    LuckyBun.flags({prod: false})
    expect(LuckyBun.dev).toBe(true)
    expect(LuckyBun.prod).toBe(false)
  })
})

describe('deepMerge', () => {
  test('merges flat objects', () => {
    const result = LuckyBun.deepMerge({a: 1, b: 2}, {b: 3, c: 4})
    expect(result).toEqual({a: 1, b: 3, c: 4})
  })

  test('merges nested objects', () => {
    const result = LuckyBun.deepMerge(
      {outer: {a: 1, b: 2}},
      {outer: {b: 3, c: 4}}
    )
    expect(result).toEqual({outer: {a: 1, b: 3, c: 4}})
  })

  test('replaces arrays instead of merging', () => {
    const result = LuckyBun.deepMerge({arr: [1, 2]}, {arr: [3, 4, 5]})
    expect(result).toEqual({arr: [3, 4, 5]})
  })

  test('handles null values', () => {
    const result = LuckyBun.deepMerge({a: {nested: 1}}, {a: null})
    expect(result).toEqual({a: null})
  })
})

describe('loadConfig', () => {
  test('uses defaults without a config file', () => {
    LuckyBun.loadConfig()
    expect(LuckyBun.config.outDir).toBe('public/assets')
    expect(LuckyBun.config.entryPoints.js).toEqual(['src/js/app.js'])
    expect(LuckyBun.config.devServer.port).toBe(3002)
    expect(LuckyBun.config.plugins).toEqual({
      css: ['cssAliases', 'cssGlobs'],
      js: ['jsGlobs']
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

  test('user can override plugins', () => {
    createFile(
      'config/bun.json',
      JSON.stringify({plugins: {css: ['cssGlobs']}})
    )

    LuckyBun.loadConfig()

    expect(LuckyBun.config.plugins).toEqual({css: ['cssGlobs']})
  })

  test('user can add JS plugins', () => {
    createFile(
      'config/bun.json',
      JSON.stringify({
        plugins: {css: ['cssAliases'], js: ['config/bun/banner.js']}
      })
    )

    LuckyBun.loadConfig()

    expect(LuckyBun.config.plugins.js).toEqual(['config/bun/banner.js'])
  })
})

describe('fingerprint', () => {
  test('returns plain filename in dev mode', () => {
    LuckyBun.prod = false
    expect(LuckyBun.fingerprint('app', '.js', 'content')).toBe('app.js')
  })

  test('returns hashed filename in prod mode', () => {
    LuckyBun.prod = true
    expect(LuckyBun.fingerprint('app', '.js', 'content')).toMatch(
      /^app-[a-f0-9]{8}\.js$/
    )
  })

  test('produces consistent hashes', () => {
    LuckyBun.prod = true
    const hash1 = LuckyBun.fingerprint('app', '.js', 'same')
    const hash2 = LuckyBun.fingerprint('app', '.js', 'same')
    expect(hash1).toBe(hash2)
  })

  test('produces different hashes for different content', () => {
    LuckyBun.prod = true
    const hash1 = LuckyBun.fingerprint('app', '.js', 'a')
    const hash2 = LuckyBun.fingerprint('app', '.js', 'b')
    expect(hash1).not.toBe(hash2)
  })
})

describe('IGNORE_PATTERNS', () => {
  const ignores = f => LuckyBun.IGNORE_PATTERNS.some(p => p.test(f))

  test('ignores editor artifacts', () => {
    expect(ignores('.#file.js')).toBe(true)
    expect(ignores('file.js~')).toBe(true)
    expect(ignores('file.swp')).toBe(true)
    expect(ignores('file.swo')).toBe(true)
    expect(ignores('file.tmp')).toBe(true)
    expect(ignores('#file.js#')).toBe(true)
  })

  test('ignores system files', () => {
    expect(ignores('.DS_Store')).toBe(true)
    expect(ignores('12345')).toBe(true)
  })

  test('allows normal files', () => {
    expect(ignores('app.js')).toBe(false)
    expect(ignores('styles.css')).toBe(false)
    expect(ignores('image.png')).toBe(false)
  })
})

describe('buildAssets', () => {
  test('builds JS files', async () => {
    await setupProject({'src/js/app.js': 'console.log("test")'})
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toBe('js/app.js')
    expect(existsSync(join(TEST_DIR, 'public/assets/js/app.js'))).toBe(true)
  })

  test('builds CSS files', async () => {
    await setupProject({'src/css/app.css': 'body { color: pink }'})
    await LuckyBun.buildCSS()

    expect(LuckyBun.manifest['css/app.css']).toBe('css/app.css')
    expect(existsSync(join(TEST_DIR, 'public/assets/css/app.css'))).toBe(true)
  })

  test('fingerprints in prod mode', async () => {
    LuckyBun.prod = true
    await setupProject({'src/js/app.js': 'console.log("prod")'})
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toMatch(/^js\/app-[a-f0-9]{8}\.js$/)
  })

  test('warns on missing entry point and continues', async () => {
    await setupProject()
    // No src/js/app.js created — should not throw
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toBeUndefined()
  })

  test('builds multiple JS entry points', async () => {
    await setupProject(
      {
        'src/js/app.js': 'console.log("app")',
        'src/js/admin.js': 'console.log("admin")'
      },
      {entryPoints: {js: ['src/js/app.js', 'src/js/admin.js']}}
    )
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toBe('js/app.js')
    expect(LuckyBun.manifest['js/admin.js']).toBe('js/admin.js')
  })

  test('builds multiple CSS entry points', async () => {
    await setupProject(
      {
        'src/css/app.css': 'body { color: red }',
        'src/css/admin.css': 'body { color: blue }'
      },
      {entryPoints: {css: ['src/css/app.css', 'src/css/admin.css']}}
    )
    await LuckyBun.buildCSS()

    expect(LuckyBun.manifest['css/app.css']).toBe('css/app.css')
    expect(LuckyBun.manifest['css/admin.css']).toBe('css/admin.css')
  })
})

describe('copyStaticAssets', () => {
  test('copies images', async () => {
    await setupProject({'src/images/logo.png': 'fake-image-data'})
    await LuckyBun.copyStaticAssets()

    expect(LuckyBun.manifest['images/logo.png']).toBe('images/logo.png')
    expect(existsSync(join(TEST_DIR, 'public/assets/images/logo.png'))).toBe(
      true
    )
  })

  test('preserves nested directory structure', async () => {
    await setupProject({'src/images/icons/arrow.svg': '<svg/>'})
    await LuckyBun.copyStaticAssets()

    expect(LuckyBun.manifest['images/icons/arrow.svg']).toBeDefined()
    expect(
      existsSync(join(TEST_DIR, 'public/assets/images/icons/arrow.svg'))
    ).toBe(true)
  })

  test('copies fonts', async () => {
    await setupProject({'src/fonts/Inter.woff2': 'fake-font-data'})
    await LuckyBun.copyStaticAssets()

    expect(LuckyBun.manifest['fonts/Inter.woff2']).toBe('fonts/Inter.woff2')
  })

  test('fingerprints static assets in prod mode', async () => {
    LuckyBun.prod = true
    await setupProject({'src/images/logo.png': 'fake-image-data'})
    await LuckyBun.copyStaticAssets()

    expect(LuckyBun.manifest['images/logo.png']).toMatch(
      /^images\/logo-[a-f0-9]{8}\.png$/
    )
  })

  test('skips missing static directories', async () => {
    await setupProject()
    await LuckyBun.copyStaticAssets()

    expect(Object.keys(LuckyBun.manifest)).toHaveLength(0)
  })
})

describe('cleanOutDir', () => {
  test('removes output directory', async () => {
    const outDir = join(TEST_DIR, 'public/assets')
    createFile('public/assets/js/old.js', 'old')
    await setupProject()
    LuckyBun.cleanOutDir()

    expect(existsSync(outDir)).toBe(false)
  })

  test('does not throw if output directory does not exist', async () => {
    await setupProject()

    expect(() => LuckyBun.cleanOutDir()).not.toThrow()
  })
})

describe('writeManifest', () => {
  test('writes manifest JSON', async () => {
    await setupProject()
    LuckyBun.manifest = {'js/app.js': 'js/app-abc123.js'}
    await LuckyBun.writeManifest()
    const manifestPath = join(
      TEST_DIR,
      'public/assets',
      LuckyBun.config.manifestPath
    )
    const content = readFileSync(manifestPath, 'utf-8')

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

describe('cssAliases plugin', () => {
  test('replaces $/ with src path in url()', async () => {
    await setupProject({
      'src/css/app.css': "body { background: url('$/images/bg.png'); }",
      'src/images/bg.png': 'fake'
    })
    await LuckyBun.buildCSS()
    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')

    expect(content).toContain('/src/')
    expect(content).not.toContain('$/')
  })

  test('replaces multiple $/ references', async () => {
    await setupProject({
      'src/css/app.css': [
        "body { background: url('$/images/bg.png'); }",
        ".icon { background: url('$/images/icon.svg'); }"
      ].join('\n'),
      'src/images/bg.png': 'fake',
      'src/images/icon.svg': '<svg/>'
    })
    await LuckyBun.buildCSS()
    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')

    expect(content).not.toContain('$/')
  })

  test('leaves non-alias urls untouched', async () => {
    await setupProject({
      'src/css/app.css':
        "body { background: url('https://example.com/bg.png'); }"
    })
    await LuckyBun.buildCSS()
    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')

    expect(content).toContain('https://example.com/bg.png')
  })
})

describe('cssGlobs plugin', () => {
  test('expands glob @import with flat wildcard', async () => {
    await setupProject({
      'src/css/app.css': "@import './components/*.css';",
      'src/css/components/button.css': '.button { color: red }',
      'src/css/components/card.css': '.card { color: blue }'
    })
    await LuckyBun.buildCSS()
    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')

    expect(content).toContain('.button')
    expect(content).toContain('.card')
  })

  test('expands glob @import with ** recursive wildcard', async () => {
    await setupProject({
      'src/css/app.css': "@import './components/**/*.css';",
      'src/css/components/button.css': '.button { color: red }',
      'src/css/components/forms/input.css': '.input { color: green }',
      'src/css/components/forms/select.css': '.select { color: blue }'
    })
    await LuckyBun.buildCSS()
    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')

    expect(content).toContain('.button')
    expect(content).toContain('.input')
    expect(content).toContain('.select')
  })

  test('does not import the file itself', async () => {
    await setupProject({
      'src/css/app.css': "@import './*.css';",
      'src/css/other.css': '.other { color: red }'
    })
    await LuckyBun.buildCSS()
    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')

    expect(content).toContain('.other')
  })

  test('handles glob matching no files', async () => {
    await setupProject({
      'src/css/app.css': "@import './empty/**/*.css';",
      'src/css/empty/.gitkeep': ''
    })
    await LuckyBun.buildCSS()
  })

  test('preserves non-glob imports', async () => {
    await setupProject({
      'src/css/app.css': [
        "@import './reset.css';",
        "@import './components/*.css';"
      ].join('\n'),
      'src/css/reset.css': '* { margin: 0 }',
      'src/css/components/button.css': '.button { color: red }'
    })
    await LuckyBun.buildCSS()
    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')

    expect(content).toContain('margin')
    expect(content).toContain('.button')
  })

  test('expands globs in deterministic sorted order', async () => {
    await setupProject({
      'src/css/app.css': "@import './components/*.css';",
      'src/css/components/zebra.css': '.zebra { order: 3 }',
      'src/css/components/alpha.css': '.alpha { order: 1 }',
      'src/css/components/middle.css': '.middle { order: 2 }'
    })
    await LuckyBun.buildCSS()
    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')
    const alphaPos = content.indexOf('.alpha')
    const middlePos = content.indexOf('.middle')
    const zebraPos = content.indexOf('.zebra')

    expect(alphaPos).toBeLessThan(middlePos)
    expect(middlePos).toBeLessThan(zebraPos)
  })
})

describe('jsGlobs plugin', () => {
  test('expands glob import into named exports', async () => {
    await setupProject(
      {
        'src/js/app.js': [
          "import components from 'glob:./components/*.js'",
          'console.log(components)'
        ].join('\n'),
        'src/js/components/modal.js': 'export default function modal() {}',
        'src/js/components/dropdown.js': 'export default function dropdown() {}'
      },
      {plugins: {js: ['jsGlobs']}}
    )
    await LuckyBun.buildJS()
    const jsPath = join(TEST_DIR, 'public/assets/js/app.js')
    const content = readFileSync(jsPath, 'utf-8')

    expect(content).toContain('modal')
    expect(content).toContain('dropdown')
  })

  test('expands recursive glob import', async () => {
    await setupProject(
      {
        'src/js/app.js': [
          "import controllers from 'glob:./controllers/**/*.js'",
          'console.log(controllers)'
        ].join('\n'),
        'src/js/controllers/nav.js': 'export default function nav() {}',
        'src/js/controllers/forms/input.js':
          'export default function input() {}'
      },
      {plugins: {js: ['jsGlobs']}}
    )
    await LuckyBun.buildJS()
    const jsPath = join(TEST_DIR, 'public/assets/js/app.js')
    const content = readFileSync(jsPath, 'utf-8')

    expect(content).toContain('nav')
    expect(content).toContain('input')
  })

  test('converts kebab-case filenames to camelCase keys', async () => {
    await setupProject(
      {
        'src/js/app.js': [
          "import components from 'glob:./components/*.js'",
          'console.log(Object.keys(components))'
        ].join('\n'),
        'src/js/components/side-panel.js':
          'export default function sidePanel() {}'
      },
      {plugins: {js: ['jsGlobs']}}
    )
    await LuckyBun.buildJS()
    const jsPath = join(TEST_DIR, 'public/assets/js/app.js')
    const content = readFileSync(jsPath, 'utf-8')

    expect(content).toContain('sidePanel()')
    expect(content).not.toContain('side-panel()')
  })

  test('handles glob matching no files', async () => {
    await setupProject(
      {
        'src/js/app.js': [
          "import components from 'glob:./components/*.js'",
          'console.log(components)'
        ].join('\n'),
        'src/js/components/.gitkeep': ''
      },
      {plugins: {js: ['jsGlobs']}}
    )
    await LuckyBun.buildJS()
    const jsPath = join(TEST_DIR, 'public/assets/js/app.js')
    const content = readFileSync(jsPath, 'utf-8')

    expect(content).toBeDefined()
  })

  test('leaves non-glob imports untouched', async () => {
    await setupProject(
      {
        'src/js/app.js': [
          "import {something} from './utils.js'",
          'console.log(something)'
        ].join('\n'),
        'src/js/utils.js': 'export const something = 42'
      },
      {plugins: {js: ['jsGlobs']}}
    )
    await LuckyBun.buildJS()
    const jsPath = join(TEST_DIR, 'public/assets/js/app.js')
    const content = readFileSync(jsPath, 'utf-8')

    expect(content).toContain('42')
  })

  test('handles multiple glob imports', async () => {
    await setupProject(
      {
        'src/js/app.js': [
          "import data from 'glob:./data/*.js'",
          "import stores from 'glob:./stores/*.js'",
          'console.log(data, stores)'
        ].join('\n'),
        'src/js/data/counter.js': 'export default function counter() {}',
        'src/js/stores/auth.js': 'export default function auth() {}'
      },
      {plugins: {js: ['jsGlobs']}}
    )
    await LuckyBun.buildJS()
    const jsPath = join(TEST_DIR, 'public/assets/js/app.js')
    const content = readFileSync(jsPath, 'utf-8')

    expect(content).toContain('counter')
    expect(content).toContain('auth')
  })

  test('expands globs in deterministic sorted order', async () => {
    await setupProject(
      {
        'src/js/app.js': [
          "import components from 'glob:./components/*.js'",
          'for (const [k, v] of Object.entries(components)) console.log(k)'
        ].join('\n'),
        'src/js/components/zebra.js': 'export default function zebra() {}',
        'src/js/components/alpha.js': 'export default function alpha() {}',
        'src/js/components/middle.js': 'export default function middle() {}'
      },
      {plugins: {js: ['jsGlobs']}}
    )
    await LuckyBun.buildJS()
    const jsPath = join(TEST_DIR, 'public/assets/js/app.js')
    const content = readFileSync(jsPath, 'utf-8')
    const alphaPos = content.indexOf('alpha')
    const middlePos = content.indexOf('middle')
    const zebraPos = content.indexOf('zebra')

    expect(alphaPos).toBeLessThan(middlePos)
    expect(middlePos).toBeLessThan(zebraPos)
  })
})

describe('plugin pipeline', () => {
  test('css plugins run in configured order', async () => {
    await setupProject({
      'src/css/app.css': [
        "@import './components/*.css';",
        "body { background: url('$/images/bg.png'); }"
      ].join('\n'),
      'src/css/components/button.css': '.button { color: red }',
      'src/images/bg.png': 'fake'
    })
    await LuckyBun.buildCSS()
    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')

    expect(content).not.toContain('$/')
    expect(content).toContain('.button')
  })

  test('disabling all plugins still builds valid CSS', async () => {
    await setupProject(
      {'src/css/app.css': 'body { color: red }'},
      {plugins: {}}
    )
    await LuckyBun.buildCSS()
    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')

    expect(content).toContain('color')
  })

  test('disabling all plugins still builds valid JS', async () => {
    await setupProject({'src/js/app.js': 'console.log("hello")'}, {plugins: {}})
    await LuckyBun.buildJS()
    const jsPath = join(TEST_DIR, 'public/assets/js/app.js')
    const content = readFileSync(jsPath, 'utf-8')

    expect(content).toContain('hello')
  })
})

describe('full build', () => {
  test('runs the complete build pipeline', async () => {
    createFile('src/js/app.js', 'console.log("built")')
    createFile('src/css/app.css', 'body { color: red }')
    createFile('src/images/logo.png', 'fake-image')
    LuckyBun.loadConfig()
    await LuckyBun.loadPlugins()
    LuckyBun.cleanOutDir()
    await LuckyBun.copyStaticAssets()
    await LuckyBun.buildJS()
    await LuckyBun.buildCSS()
    await LuckyBun.writeManifest()
    const manifestPath = join(
      TEST_DIR,
      'public/assets',
      LuckyBun.config.manifestPath
    )

    expect(LuckyBun.manifest['js/app.js']).toBeDefined()
    expect(LuckyBun.manifest['css/app.css']).toBeDefined()
    expect(LuckyBun.manifest['images/logo.png']).toBeDefined()
    expect(existsSync(manifestPath)).toBe(true)
  })

  test('clean build removes previous output', async () => {
    createFile('public/assets/js/stale.js', 'old stuff')
    createFile('src/js/app.js', 'console.log("fresh")')
    LuckyBun.loadConfig()
    await LuckyBun.loadPlugins()
    LuckyBun.cleanOutDir()
    await LuckyBun.buildJS()

    expect(existsSync(join(TEST_DIR, 'public/assets/js/stale.js'))).toBe(false)
    expect(existsSync(join(TEST_DIR, 'public/assets/js/app.js'))).toBe(true)
  })
})

describe('prettyManifest', () => {
  test('formats manifest entries', () => {
    LuckyBun.manifest = {
      'js/app.js': 'js/app-abc123.js',
      'css/app.css': 'css/app-def456.css'
    }
    const output = LuckyBun.prettyManifest()

    expect(output).toContain('js/app.js → js/app-abc123.js')
    expect(output).toContain('css/app.css → css/app-def456.css')
  })

  test('returns newlines for empty manifest', () => {
    LuckyBun.manifest = {}
    const output = LuckyBun.prettyManifest()

    expect(output).toContain('\n')
  })
})
