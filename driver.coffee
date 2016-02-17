# present simple interface over jison grammar in grammar.jison

ParseC = require('./c.tab').parse

doParseStream = (stream, cb) ->
  buf = ''
  stream.on 'data', (data) -> buf += data.toString()
  stream.on 'end', ->
    try
      res = ParseC buf
      cb null, res
    catch err then cb err

traverseTree = (obj) ->
  console.log obj
  console.log obj.children()

doParseStream process.stdin, (err, parsed) ->
  if err then throw err
  else traverseTree parsed
