const REGEX = /(url\(\s*['"]?|(?<!\w)['"](?:glob:)?)\$\//g

// Resolves `$/` root aliases in CSS url() references and JS/CSS imports.
// e.g. url('$/src/images/foo.png') → url('/absolute/root/src/images/foo.png')
//      import x from '$/lib/utils.js' → import x from '/absolute/root/lib/utils.js'
//      @import '$/src/css/reset.css' → @import '/absolute/root/src/css/reset.css'
export default function aliases({root}) {
  return content => content.replace(REGEX, `$1${root}/`)
}
