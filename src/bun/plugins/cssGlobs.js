import {dirname, relative, resolve, join} from 'path'
import {Glob} from 'bun'

const REGEX = /@import\s+['"]([^'"]*\*[^'"]*)['"]\s*;/g

// Expands glob patterns in CSS @import statements.
// e.g. @import './components/**/*.css' → individual @import lines.
export default function cssGlobs() {
  return async (content, args) => {
    const fileDir = dirname(args.path)
    const replacements = []

    for (const [fullMatch, pattern] of content.matchAll(REGEX)) {
      const parts = pattern.split('/')
      const globStart = parts.findIndex(p => p.includes('*'))
      const basePath = parts.slice(0, globStart).join('/')
      const globPattern = parts.slice(globStart).join('/')
      const baseDir = resolve(fileDir, basePath)
      const glob = new Glob(globPattern)
      const files = []

      for await (const file of glob.scan({cwd: baseDir, onlyFiles: true})) {
        const absPath = join(baseDir, file)
        if (absPath === args.path) continue
        const relPath = relative(fileDir, absPath)
        files.push(relPath.startsWith('.') ? relPath : `./${relPath}`)
      }

      files.sort()

      if (!files.length) console.warn(` ▸ Glob matched no files: ${pattern}`)

      replacements.push({
        fullMatch,
        expanded: files.map(f => `@import '${f}';`).join('\n'),
        count: files.length,
        pattern
      })
    }

    for (const {fullMatch, expanded, count, pattern} of replacements) {
      const s = count !== 1 ? 's' : ''
      console.log(` ▸ Glob: ${pattern} → ${count} file${s}`)
      content = content.replace(fullMatch, expanded)
    }

    return content
  }
}
