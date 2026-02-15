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
  LuckyBun.prod = false
  LuckyBun.dev = false
})

afterAll(() => {
  rmSync(TEST_DIR, {recursive: true, force: true})
})

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
    LuckyBun.root = TEST_DIR
    LuckyBun.loadConfig()
    expect(LuckyBun.config.outDir).toBe('public/assets')
    expect(LuckyBun.config.entryPoints.js).toEqual(['src/js/app.js'])
    expect(LuckyBun.config.devServer.port).toBe(3002)
  })

  test('merges user config with defaults', () => {
    mkdirSync(join(TEST_DIR, 'config'), {recursive: true})
    writeFileSync(
      join(TEST_DIR, 'config/bun.json'),
      JSON.stringify({outDir: 'dist', devServer: {port: 4000}})
    )

    LuckyBun.root = TEST_DIR
    LuckyBun.loadConfig()

    expect(LuckyBun.config.outDir).toBe('dist')
    expect(LuckyBun.config.devServer.port).toBe(4000)
    expect(LuckyBun.config.devServer.host).toBe('127.0.0.1')
    expect(LuckyBun.config.entryPoints.js).toEqual(['src/js/app.js'])
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
    mkdirSync(join(TEST_DIR, 'src/js'), {recursive: true})
    mkdirSync(join(TEST_DIR, 'public/assets'), {recursive: true})
    writeFileSync(join(TEST_DIR, 'src/js/app.js'), 'console.log("test")')

    LuckyBun.root = TEST_DIR
    LuckyBun.loadConfig()
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toBe('js/app.js')
    expect(existsSync(join(TEST_DIR, 'public/assets/js/app.js'))).toBe(true)
  })

  test('builds CSS files', async () => {
    mkdirSync(join(TEST_DIR, 'src/css'), {recursive: true})
    writeFileSync(join(TEST_DIR, 'src/css/app.css'), 'body { color: pink }')

    LuckyBun.root = TEST_DIR
    LuckyBun.loadConfig()
    await LuckyBun.buildCSS()

    expect(LuckyBun.manifest['css/app.css']).toBe('css/app.css')
    expect(existsSync(join(TEST_DIR, 'public/assets/css/app.css'))).toBe(true)
  })

  test('fingerprints in prod mode', async () => {
    mkdirSync(join(TEST_DIR, 'src/js'), {recursive: true})
    writeFileSync(join(TEST_DIR, 'src/js/app.js'), 'console.log("prod")')

    LuckyBun.root = TEST_DIR
    LuckyBun.prod = true
    LuckyBun.loadConfig()
    await LuckyBun.buildJS()

    expect(LuckyBun.manifest['js/app.js']).toMatch(/^js\/app-[a-f0-9]{8}\.js$/)
  })
})

describe('copyStaticAssets', () => {
  test('copies images', async () => {
    mkdirSync(join(TEST_DIR, 'src/images'), {recursive: true})
    writeFileSync(join(TEST_DIR, 'src/images/logo.png'), 'fake-image-data')

    LuckyBun.root = TEST_DIR
    LuckyBun.loadConfig()
    await LuckyBun.copyStaticAssets()

    expect(LuckyBun.manifest['images/logo.png']).toBe('images/logo.png')
    expect(existsSync(join(TEST_DIR, 'public/assets/images/logo.png'))).toBe(
      true
    )
  })

  test('preserves nested directory structure', async () => {
    mkdirSync(join(TEST_DIR, 'src/images/icons'), {recursive: true})
    writeFileSync(join(TEST_DIR, 'src/images/icons/arrow.svg'), '<svg/>')

    LuckyBun.root = TEST_DIR
    LuckyBun.loadConfig()
    await LuckyBun.copyStaticAssets()

    expect(LuckyBun.manifest['images/icons/arrow.svg']).toBeDefined()
  })
})

describe('cleanOutDir', () => {
  test('removes output directory', () => {
    const outDir = join(TEST_DIR, 'public/assets')
    mkdirSync(join(outDir, 'js'), {recursive: true})
    writeFileSync(join(outDir, 'js/old.js'), 'old')

    LuckyBun.root = TEST_DIR
    LuckyBun.loadConfig()
    LuckyBun.cleanOutDir()

    expect(existsSync(outDir)).toBe(false)
  })
})

describe('writeManifest', () => {
  test('writes manifest JSON', async () => {
    LuckyBun.root = TEST_DIR
    LuckyBun.loadConfig()
    LuckyBun.manifest = {'js/app.js': 'js/app-abc123.js'}

    await LuckyBun.writeManifest()

    const content = readFileSync(
      join(TEST_DIR, 'public/assets/manifest.json'),
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
    LuckyBun.root = TEST_DIR
    LuckyBun.loadConfig()
    expect(LuckyBun.outDir).toBe(join(TEST_DIR, 'public/assets'))
  })
})

describe('cssAliasPlugin', () => {
  test('replaces $/ with src path', async () => {
    mkdirSync(join(TEST_DIR, 'src/css'), {recursive: true})
    mkdirSync(join(TEST_DIR, 'src/images'), {recursive: true})
    writeFileSync(join(TEST_DIR, 'src/images/bg.png'), 'fake')
    writeFileSync(
      join(TEST_DIR, 'src/css/app.css'),
      "body { background: url('$/images/bg.png'); }"
    )

    LuckyBun.root = TEST_DIR
    LuckyBun.loadConfig()
    await LuckyBun.buildCSS()

    const cssPath = join(TEST_DIR, 'public/assets/css/app.css')
    const content = readFileSync(cssPath, 'utf-8')
    expect(content).toContain('/src/')
    expect(content).not.toContain('$/')
  })
})
