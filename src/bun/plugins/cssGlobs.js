import {dirname, relative, resolve, join} from 'path'
import {Glob} from 'bun'

const IMPORT_RE =
  /@import\s+['"]([^'"]*\*[^'"]*)['"]((?:\s+not\s+['"][^'"]*['"])*)\s*;/g
const NOT_RE = /not\s+['"]([^'"]*)['"]/g

function parseImport(match) {
  const nots = [...(match[2] || '').matchAll(NOT_RE)]
  return {pattern: match[1], excludes: nots.map(m => m[1])}
}

function splitGlob(pattern) {
  const i = pattern.lastIndexOf('/', pattern.indexOf('*'))
  const base = i > 0 ? pattern.slice(0, i) : '.'
  return {base, glob: pattern.slice(i + 1)}
}

function stripPrefix(path, prefix) {
  const p = prefix.replace(/\/$/, '') + '/'
  return path.startsWith(p) ? path.slice(p.length) : path
}

function excluded(file, matchers) {
  return matchers.some(m => m.match(file))
}

async function scanFiles(fileDir, pattern, excludes) {
  const {base, glob: globPart} = splitGlob(pattern)
  const baseDir = resolve(fileDir, base)
  const matchers = excludes.map(e => new Glob(stripPrefix(e, base)))
  const glob = new Glob(globPart)
  const files = []

  for await (const file of glob.scan({cwd: baseDir, onlyFiles: true})) {
    if (excluded(file, matchers)) continue
    const abs = join(baseDir, file)
    const rel = relative(fileDir, abs)
    files.push(rel.startsWith('.') ? rel : `./${rel}`)
  }

  return files.sort()
}

export default function cssGlobs() {
  return async (content, args) => {
    const fileDir = dirname(args.path)
    const replacements = []

    for (const match of content.matchAll(IMPORT_RE)) {
      const {pattern, excludes} = parseImport(match)
      const files = (await scanFiles(fileDir, pattern, excludes)).filter(
        f => resolve(fileDir, f) !== args.path
      )

      const label =
        pattern +
        (excludes.length
          ? ` (${excludes.length} exclusion${excludes.length > 1 ? 's' : ''})`
          : '')

      if (!files.length) console.warn(`  CSS glob matched no files: ${label}`)

      const s = files.length !== 1 ? 's' : ''
      console.log(`  CSS glob: ${label} → ${files.length} file${s}`)

      replacements.push({
        fullMatch: match[0],
        expanded: files.map(f => `@import '${f}';`).join('\n')
      })
    }

    for (const {fullMatch, expanded} of replacements)
      content = content.replace(fullMatch, expanded)

    return content
  }
}
