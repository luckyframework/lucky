import LuckyBun from './lucky.js'

LuckyBun.flags({
  debug: process.argv.includes('--debug'),
  dev: process.argv.includes('--dev'),
  prod: process.argv.includes('--prod')
})

await LuckyBun.bake()
