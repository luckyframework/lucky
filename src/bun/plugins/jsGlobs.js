import {basename, dirname, join, relative} from 'path'
import {Glob} from 'bun'

const REGEX = /import\s+(\w+)\s+from\s+['"]glob:([^'"]+)['"]/g

export default function jsGlobs() {
  return (content, args) => {
    if (!REGEX.test(content)) return content

    REGEX.lastIndex = 0

    return content.replace(REGEX, (match, binding, pattern) => {
      const dir = dirname(args.path)
      const glob = new Glob(pattern)
      const files = Array.from(glob.scanSync({cwd: dir})).sort()

      if (!files.length) return `const ${binding} = {}`

      const imports = []
      const entries = []

      for (const file of files) {
        const name = basename(file, '.js')
          .replace(/_|\//g, '-')
          .replace(/-([a-z])/g, (_, l) => l.toUpperCase())
        const safe = `_glob_${name}`
        imports.push(`import ${safe} from './${file}'`)
        entries.push(`  '${name}': ${safe}`)
      }

      return [
        ...imports,
        `const ${binding} = {`,
        entries.join(',\n'),
        '}'
      ].join('\n')
    })
  }
}
