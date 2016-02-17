# present simple interface over jison grammar in grammar.jison

selectree = require '../selectree'
ParseC = require('./c.tab').parse

doParseStream = (stream, cb) ->
  buf = ''
  stream.on 'data', (data) -> buf += data.toString()
  stream.on 'end', ->
    try
      res = ParseC buf
      cb null, res
    catch err then cb err

VariableNameQuery = 'IDENTIFIER'
ConstantValueQuery = 'CONSTANT'

traverseTree = (obj) ->
  tree = selectree obj, {xml: yes, name: 'name', children: 'children'}
  console.log Array.from(tree.css(VariableNameQuery))[0].children()[0].name();
  console.log Array.from(tree.css(ConstantValueQuery))[0].children()[0].name()

doParseStream process.stdin, (err, parsed) ->
  if err then throw err
  else traverseTree parsed
