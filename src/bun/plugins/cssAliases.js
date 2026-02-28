import {join} from 'path'

const REGEX = /url\(\s*['"]?\$\//g

// Resolves `$` root aliases in CSS url() references.
// e.g. url('$/images/foo.png') → url('/absolute/src/images/foo.png')
export default function cssAliases({root}) {
  const srcDir = join(root, 'src')
  return content => content.replace(REGEX, `url('${srcDir}/`)
}
