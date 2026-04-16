import {dirname, extname, isAbsolute, relative, join} from 'path'
import {Glob} from 'bun'

const REGEX = /import\s+(\w+)\s+from\s+['"]glob:([^'"]+)['"]/g

function parseImport(raw) {
  const parts = raw.split(/\s+not\s+/)
  return {pattern: parts[0], excludes: parts.slice(1)}
}

function splitBase(pattern) {
  const clean = pattern.replace(/^\.\//, '')
  const base = clean.slice(0, clean.search(/[*?{[]|$/)).replace(/\/$/, '')
  return {clean, base}
}

function excluded(file, matchers) {
  return matchers.some(m => m.match(file))
}

function scanFiles(dir, pattern, excludes) {
  const {clean, base} = splitBase(pattern)
  const abs = isAbsolute(clean)
  const cwd = abs ? base : dir
  const globPart = abs ? clean.slice(base.length + 1) : clean
  const matchers = excludes.map(e => {
    const ex = e.replace(/^\.\//, '')
    return new Glob(abs && isAbsolute(ex) ? ex.slice(base.length + 1) : ex)
  })
  const glob = new Glob(globPart)
  const files = []

  for (const file of glob.scanSync({cwd})) {
    if (excluded(file, matchers)) continue
    const absPath = join(cwd, file)
    const rel = relative(dir, absPath)
    files.push(rel)
  }

  return files.sort()
}

function keyBase(pattern) {
  const {base} = splitBase(pattern)
  if (!isAbsolute(base)) return base
  const last = base.lastIndexOf('/')
  return last > 0 ? base.slice(last + 1) : base
}

function buildImportMap(files, dir, base) {
  const imports = []
  const entries = []

  for (const file of files) {
    const ext = extname(file)
    const key = file
      .slice(0, -ext.length)
      .replace(/^[./]+/, '')
      .replace(new RegExp(`^.*${base}/`), '')
    const safe = `_glob_${base}_${key}`.replace(/[^a-zA-Z0-9]/g, '_')
    const rel = file.startsWith('.') ? file : `./${file}`
    imports.push(`import ${safe} from '${rel}'`)
    entries.push(`  '${key}': ${safe}`)
  }

  return {imports, entries}
}

export default function jsGlobs() {
  return (content, args) => {
    return content.replace(REGEX, (_, binding, raw) => {
      const {pattern, excludes} = parseImport(raw)
      const base = keyBase(pattern)
      const dir = dirname(args.path)
      const files = scanFiles(dir, pattern, excludes)

      if (!files.length) return `const ${binding} = {}`

      const {imports, entries} = buildImportMap(files, dir, base)

      return [
        ...imports,
        `const ${binding} = {`,
        entries.join(',\n'),
        '}'
      ].join('\n')
    })
  }
}
