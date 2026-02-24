import LuckyBun from './lucky.js'

LuckyBun.flags({
  dev: process.argv.includes('--dev'),
  prod: process.argv.includes('--prod')
})

await LuckyBun.bake()
