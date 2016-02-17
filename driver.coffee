# present simple interface over jison grammar in grammar.jison

ParseC = require('./c.tab').parse

doParseStream = (stream, cb) ->
  buf = ''
  s.on 'data', (data) -> buf += data.toString()
  s.on 'finish', ->
    try
      res = ParseC buf
      cb null, res
    catch err then cb err

doParseStream process.stdin, (err, parsed) ->
  if err then throw err
  else console.log parsed
