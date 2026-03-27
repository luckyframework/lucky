import {dirname, extname} from 'path'
import {Glob} from 'bun'

const REGEX = /import\s+(\w+)\s+from\s+['"]glob:([^'"]+)['"]/g

// Compiles an object with a file path => default export mapping from a glob
// pattern in JS import statements.
// e.g. import components from 'glob:./components/**/*.js'
//
// ... will generate ...
//
// import _glob_components_theme from './components/theme.js'
// import _glob_components_shared_tooltip from './components/shared/tooltip.js'
// const components = {
//   'theme': _glob_components_theme,
//   'shared/tooltip': _glob_components_shared_tooltip
// }
export default function jsGlobs() {
  return (content, args) => {
    return content.replace(REGEX, (_, binding, pattern) => {
      const dir = dirname(args.path)
      const cleanPattern = pattern.replace(/^\.\//, '')
      const baseDir = cleanPattern.slice(0, cleanPattern.search(/[*?{[]|$/))
        .replace(/\/$/, '')
      const glob = new Glob(cleanPattern)
      const files = Array.from(glob.scanSync({cwd: dir})).sort()

      if (!files.length) return `const ${binding} = {}`

      const imports = []
      const entries = []

      for (const file of files) {
        const ext = extname(file)
        const relative = baseDir ? file.slice(baseDir.length + 1) : file
        const key = relative.slice(0, -ext.length)
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
