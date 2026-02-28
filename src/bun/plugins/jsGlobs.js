import {dirname, extname} from 'path'
import {Glob} from 'bun'

const REGEX = /import\s+(\w+)\s+from\s+['"]glob:([^'"]+)['"]/g

export default function jsGlobs() {
  return (content, args) => {
    if (!REGEX.test(content)) return content

    REGEX.lastIndex = 0

    return content.replace(REGEX, (_, binding, pattern) => {
      const dir = dirname(args.path)
      const cleanPattern = pattern.replace(/^\.\//, '')
      const glob = new Glob(cleanPattern)
      const files = Array.from(glob.scanSync({cwd: dir})).sort()

      if (!files.length) return `const ${binding} = {}`

      const imports = []
      const entries = []

      for (const file of files) {
        const ext = extname(file)
        const key = file.slice(0, -ext.length)
        const safe = `_glob_${key.replace(/[^a-zA-Z0-9]/g, '_')}`
        imports.push(`import ${safe} from './${file}'`)
        entries.push(`  '${key}': ${safe}`)
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
