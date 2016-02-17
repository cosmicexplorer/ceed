# present simple interface over jison grammar in grammar.jison

{Writable} = require 'stream'
{parse} = require './c.tab'

class ParseStream extends Writable
  constructor: (opts={}) ->
    if @ instanceof ParseStream
      return new ParseStream opts
    else Writable.call @, opts

    @buf = ''

  _write: (chunk, enc, cb) ->
    @buf += chunk.toString()
    cb()

  getBuffer: -> @buf

doParseStream = (stream, cb) ->
  s = stream.pipe new ParseStream
  s.on 'finish', ->
    try res = parse s.getBuffer()
    catch err then cb err
    cb null, res
