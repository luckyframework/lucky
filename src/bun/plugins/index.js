import {join} from 'path'
import aliases from './aliases.js'
import cssGlobs from './cssGlobs.js'
import jsGlobs from './jsGlobs.js'

const builtins = {aliases, cssGlobs, jsGlobs}
const TYPE_REGEXES = {
  css: /\.css$/,
  js: /\.(js|ts|jsx|tsx)$/
}

// Combines transform functions into a single Bun plugin for a given file type.
function transformPipeline(type, transforms) {
  const filter = TYPE_REGEXES[type]

  return {
    name: `${type}-transforms`,
    setup(build) {
      build.onLoad({filter}, async args => {
        let content = await Bun.file(args.path).text()
        for (const transform of transforms)
          content = await transform(content, args)
        return {contents: content, loader: type}
      })
    }
  }
}

// Resolves a plugin name or path into a transform function.
async function loadFactory(name, root) {
  if (builtins[name]) return builtins[name]

  try {
    const mod = await import(join(root, name))
    console.log(` ▸ Loaded custom plugin: ${name}`)
    return mod.default || mod
  } catch (err) {
    console.error(` ✖ Failed to load plugin "${name}": ${err.message}`)
  }
}

// Resolves plugin names into transforms for a single type.
async function resolveType(names, context) {
  const transforms = []
  const plugins = []

  for (const name of names) {
    const factory = await loadFactory(name, context.root)
    if (typeof factory !== 'function') {
      if (factory != null)
        console.error(` ✖ Plugin "${name}" does not export a function`)
      continue
    }

    const result = factory(context)
    if (typeof result === 'function') transforms.push(result)
    else if (result?.setup) plugins.push(result)
    else console.error(` ✖ Plugin "${name}" returned an invalid value`)
  }

  return {transforms, plugins}
}

// Resolves plugin config into Bun plugin instances.
export async function resolvePlugins(pluginConfig, context) {
  const bunPlugins = []

  if (!pluginConfig || typeof pluginConfig !== 'object') return bunPlugins

  for (const [type, names] of Object.entries(pluginConfig)) {
    if (!Array.isArray(names)) continue

    if (!TYPE_REGEXES[type]) {
      console.error(` ✖ Unknown plugin type "${type}"`)
      continue
    }

    const {transforms, plugins} = await resolveType(names, context)
    bunPlugins.push(...plugins)
    if (transforms.length)
      bunPlugins.unshift(transformPipeline(type, transforms))
  }

  return bunPlugins
}
