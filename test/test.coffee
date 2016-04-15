{parse: parseC} = require '../c.tab'
{spawn} = require 'child_process'
DumpStream = require 'dump-stream'

module.exports =
  'parseSomething': (test) ->
    test.expect 1
    proc = spawn "#{__dirname}/test.sh"
    strstr = new DumpStream
    proc.on 'error', (err) ->
      console.error err
      test.done()
    proc.stdout.pipe(strstr).on 'finish', ->
      str = strstr.dump()
      try
        res = parseC(str)
        test.ok res
        console.log res
      catch err
        console.error err
      finally test.done()
