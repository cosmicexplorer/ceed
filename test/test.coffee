{parse: parseC} = require '../c.tab'
fs = require 'fs'

module.exports =
  'parseSomething': (test) ->
    test.expect 1
    str = fs.readFileSync("#{__dirname}/test.c").toString()
    try
      res = parseC(str)
      test.ok res
      console.log res
    catch err then console.error err.stack
    finally test.done()
