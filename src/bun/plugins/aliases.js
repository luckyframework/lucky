const CSS_REGEX = /((?:url\(\s*|@import\s+)['"]?(?:glob:)?)\$\//g
const JS_REGEX =
  /((?:from\s+|require\s*\(\s*|import\s*\(\s*)['"](?:glob:)?)\$\//g

// Resolves `$/` root aliases in CSS url() references and JS/CSS imports.
// e.g. url('$/src/images/foo.png') → url('/absolute/root/src/images/foo.png')
//      import x from '$/lib/utils.js' → import x from '/absolute/root/lib/utils.js'
//      @import '$/src/css/reset.css' → @import '/absolute/root/src/css/reset.css'
export default function aliases({root}) {
  return (content, args) => {
    const regex = args.path.endsWith('.css') ? CSS_REGEX : JS_REGEX
    return content.replace(regex, `$1${root}/`)
  }
}
